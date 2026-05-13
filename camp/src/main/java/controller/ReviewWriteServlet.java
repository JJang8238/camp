package controller;

import dao.PlaceReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.apache.commons.fileupload2.core.DiskFileItem;
import org.apache.commons.fileupload2.core.DiskFileItemFactory;
import org.apache.commons.fileupload2.jakarta.servlet6.JakartaServletDiskFileUpload;
import org.apache.commons.fileupload2.jakarta.servlet6.JakartaServletFileUpload;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@WebServlet("/reviewWrite")
public class ReviewWriteServlet extends HttpServlet {

    private static final long   MAX_FILE_SIZE   = 10 * 1024 * 1024L;
    private static final int    MAX_PHOTO_COUNT = 3;
    private static final String IMG_DIR_WEB     = "/assets/img/reviews/";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        Integer userId = (Integer) req.getSession().getAttribute("userId");
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action       = "";
        String place        = "";
        String sort         = "newest";
        String content      = "";
        int    rating       = 5;
        int    postId       = 0;
        String removeImages = "";
        List<DiskFileItem> photoItems = new ArrayList<>();

        try {
            if (JakartaServletFileUpload.isMultipartContent(req)) {
                DiskFileItemFactory factory = DiskFileItemFactory.builder().get();
                JakartaServletDiskFileUpload upload = new JakartaServletDiskFileUpload(factory);
                upload.setFileSizeMax(MAX_FILE_SIZE);

                List<DiskFileItem> items = upload.parseRequest(req);
                for (DiskFileItem item : items) {
                    if (item.isFormField()) {
                        String name  = item.getFieldName();
                        String value = item.getString(StandardCharsets.UTF_8);
                        switch (name) {
                            case "action":       action       = value; break;
                            case "place":        place        = value; break;
                            case "sort":         sort         = value; break;
                            case "content":      content      = value; break;
                            case "rating":       try { rating = Integer.parseInt(value); } catch (Exception ignored) {} break;
                            case "id":           try { postId = Integer.parseInt(value); } catch (Exception ignored) {} break;
                            case "removeImages": removeImages = value; break;
                        }
                    } else {
                        if ("photos".equals(item.getFieldName()) && item.getSize() > 0) {
                            photoItems.add(item);
                        }
                    }
                }
            } else {
                action  = orEmpty(req.getParameter("action"));
                place   = orEmpty(req.getParameter("place"));
                sort    = orEmpty(req.getParameter("sort"));
                content = orEmpty(req.getParameter("content"));
                try { rating = Integer.parseInt(req.getParameter("rating")); } catch (Exception ignored) {}
                try { postId = Integer.parseInt(req.getParameter("id"));     } catch (Exception ignored) {}
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/review.jsp?place=" + enc(place) + "&sort=" + sort);
            return;
        }

        if (sort.isEmpty()) sort = "newest";

        String realBase = req.getServletContext().getRealPath(IMG_DIR_WEB);
        File uploadDir  = new File(realBase);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        PlaceReviewDAO dao = new PlaceReviewDAO();
        String redirect = req.getContextPath() + "/review.jsp?place=" + enc(place) + "&sort=" + sort;

        if ("write".equals(action)) {
            List<String> saved     = savePhotos(photoItems, uploadDir);
            String       thumbnail = saved.isEmpty() ? null : IMG_DIR_WEB + saved.get(0);
            dao.insertReviewWithImages(userId, place, content, rating, thumbnail, saved, IMG_DIR_WEB);

        } else if ("edit".equals(action) && postId > 0) {
            if (!removeImages.isEmpty()) {
                for (String idStr : removeImages.split(",")) {
                    try {
                        int    imgId   = Integer.parseInt(idStr.trim());
                        String imgPath = dao.getImagePathById(imgId);
                        dao.deletePostImage(imgId, postId);
                        if (imgPath != null) deleteFile(req, imgPath);
                    } catch (Exception ignored) {}
                }
            }
            List<String> saved = savePhotos(photoItems, uploadDir);
            dao.updateReview(postId, userId, content, rating);
            if (!saved.isEmpty()) {
                dao.insertPostImages(postId, saved, IMG_DIR_WEB);
                dao.updateThumbnailIfEmpty(postId, IMG_DIR_WEB + saved.get(0));
            }

        } else if ("delete".equals(action) && postId > 0) {
            List<String> imgPaths = dao.getPostImagePaths(postId);
            dao.deleteReview(postId, userId);
            for (String p : imgPaths) deleteFile(req, p);
        }

        resp.sendRedirect(redirect);
    }

    private List<String> savePhotos(List<DiskFileItem> items, File uploadDir) throws IOException {
        List<String> result = new ArrayList<>();
        int count = 0;
        for (DiskFileItem item : items) {
            if (count >= MAX_PHOTO_COUNT) break;
            String ext = getExt(item.getName());
            if (ext == null) continue;
            String fileName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            Path dest = Paths.get(uploadDir.getAbsolutePath(), fileName);
            try (InputStream in = item.getInputStream()) {
                Files.copy(in, dest);
            }
            result.add(fileName);
            count++;
        }
        return result;
    }

    private String getExt(String fileName) {
        if (fileName == null || fileName.isEmpty()) return null;
        int dot = fileName.lastIndexOf('.');
        if (dot < 0) return null;
        String ext = fileName.substring(dot + 1).toLowerCase();
        return ext.matches("jpg|jpeg|png|gif|webp") ? ext : null;
    }

    private void deleteFile(HttpServletRequest req, String webPath) {
        try {
            String real = req.getServletContext().getRealPath(webPath);
            if (real != null) new File(real).delete();
        } catch (Exception ignored) {}
    }

    private String enc(String s) {
        try { return java.net.URLEncoder.encode(s == null ? "" : s, "UTF-8"); }
        catch (Exception e) { return ""; }
    }

    private String orEmpty(String s) { return s == null ? "" : s; }
}
