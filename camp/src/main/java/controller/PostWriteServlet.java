package controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.UUID;

import dao.PostDAO;
import dto.EventDetail;
import dto.Post;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/post/write")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 50 * 1024 * 1024
)
public class PostWriteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();

        Integer authorId = (Integer) request.getSession().getAttribute("userId");
        if (authorId == null) {
            response.sendRedirect(ctx + "/login.jsp");
            return;
        }

        String postType = nvl(request.getParameter("postType"));
        String title = nvl(request.getParameter("title"));
        String summary = nvl(request.getParameter("summary"));
        String content = nvl(request.getParameter("content"));
        String category = nvl(request.getParameter("category"));
        String status = nvl(request.getParameter("status"));
        String publishedAt = nvl(request.getParameter("publishedAt"));
        String thumbnailPath = nvl(request.getParameter("thumbnailPath"));

        int isPinned = parseInt(request.getParameter("isPinned"), 0);
        int displayOrder = parseInt(request.getParameter("displayOrder"), 0);

        if (postType.isEmpty() || title.isEmpty() || content.isEmpty()) {
            script(response, "필수값이 비어 있습니다.", "history.back();");
            return;
        }

        String thumbnail = thumbnailPath;

        Part imagePart = null;
        try {
            imagePart = request.getPart("imageFile");
        } catch (Exception e) {
            imagePart = null;
        }

        if (imagePart != null && imagePart.getSize() > 0) {
            String originalFileName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
            String ext = "";

            int dotIdx = originalFileName.lastIndexOf(".");
            if (dotIdx > -1) {
                ext = originalFileName.substring(dotIdx);
            }

            String savedName = UUID.randomUUID().toString().replace("-", "") + ext;

            String uploadDirPath = getServletContext().getRealPath("/assets/upload");
            File uploadDir = new File(uploadDirPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            imagePart.write(uploadDirPath + File.separator + savedName);
            thumbnail = request.getContextPath() + "/assets/upload/" + savedName;
        }

        Post post = new Post();
        post.setPostType(postType);
        post.setTitle(title);
        post.setSummary(summary);
        post.setContent(content);
        post.setCategory(category);
        post.setThumbnail(thumbnail);
        post.setAuthorId(authorId);
        post.setStatus(status.isEmpty() ? "draft" : status);
        post.setIsPinned(isPinned);
        post.setDisplayOrder(displayOrder);
        post.setPublishedAt(publishedAt);

        PostDAO dao = new PostDAO();
        int postId = dao.insertPost(post);

        if (postId <= 0) {
            script(response, "게시물 저장에 실패했습니다.", "history.back();");
            return;
        }

        if ("event".equals(postType)) {
            EventDetail event = new EventDetail();
            event.setPostId(postId);
            event.setStartDate(nvl(request.getParameter("startDate")));
            event.setEndDate(nvl(request.getParameter("endDate")));
            event.setEventStatus(defaultIfEmpty(request.getParameter("eventStatus"), "upcoming"));
            event.setApplyUrl(nvl(request.getParameter("applyUrl")));
            event.setCouponCode(nvl(request.getParameter("couponCode")));

            String maxParticipantsStr = nvl(request.getParameter("maxParticipants"));
            if (!maxParticipantsStr.isEmpty()) {
                event.setMaxParticipants(parseInt(maxParticipantsStr, 0));
            }

            event.setWinnerAnnounceAt(nvl(request.getParameter("winnerAnnounceAt")));

            boolean detailOk = dao.insertEventDetail(event);
            if (!detailOk) {
                script(response, "이벤트 상세 저장에 실패했습니다.", "history.back();");
                return;
            }
        }

        if ("event".equals(postType)) {
            script(response, "이벤트가 등록되었습니다.", "location.href='" + ctx + "/eventList.jsp';");
        } else {
            script(response, "소식이 등록되었습니다.", "location.href='" + ctx + "/newsList.jsp';");
        }
    }

    private String nvl(String s) {
        return s == null ? "" : s.trim();
    }

    private String defaultIfEmpty(String s, String def) {
        return (s == null || s.trim().isEmpty()) ? def : s.trim();
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    private void script(HttpServletResponse response, String msg, String action) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<script>");
        response.getWriter().println("alert('" + msg.replace("'", "\\'") + "');");
        response.getWriter().println(action);
        response.getWriter().println("</script>");
    }
}