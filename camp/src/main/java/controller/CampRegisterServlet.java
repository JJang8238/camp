package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import util.DBUtil;
import dao.UserDAO;
import dto.User;

import software.amazon.awssdk.auth.credentials.InstanceProfileCredentialsProvider;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/owner/registerCamp")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,
    maxFileSize       = 1024 * 1024 * 10,
    maxRequestSize    = 1024 * 1024 * 15
)
public class CampRegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String BUCKET = System.getenv("S3_BUCKET");
    private static final String REGION  = System.getenv("AWS_REGION") != null
                                            ? System.getenv("AWS_REGION")
                                            : "ap-northeast-2";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();

        Integer loginUserId = (Integer) request.getSession().getAttribute("userId");
        if (loginUserId == null) {
            response.sendRedirect(ctx + "/login.jsp");
            return;
        }

        UserDAO userDAO = new UserDAO();
        User loginUser = userDAO.getUserById(loginUserId);
        if (loginUser == null || !"owner".equalsIgnoreCase(loginUser.getRole())) {
            response.sendRedirect(ctx + "/main.jsp");
            return;
        }

        String name        = request.getParameter("name");
        String address     = request.getParameter("address");
        String type        = request.getParameter("type");
        String tags        = request.getParameter("tags");
        String priceStr    = request.getParameter("price");
        String status      = request.getParameter("status");
        String description = request.getParameter("description");

        if (name == null || name.trim().isEmpty()
                || address == null || address.trim().isEmpty()) {
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<script>alert('필수값이 누락되었습니다.'); history.back();</script>");
            return;
        }

        if (type == null) type = "";
        if (tags == null) tags = "";
        if (status == null || status.trim().isEmpty()) status = "active";
        if (description == null) description = "";

        int price = 0;
        try { price = Integer.parseInt(priceStr); } catch (Exception e) { price = 0; }

        Part filePart = request.getPart("imageFile");
        String imagePath = "";

        if (filePart != null && filePart.getSize() > 0) {
            String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String ext = "";
            int dotIdx = originalFileName.lastIndexOf(".");
            if (dotIdx != -1) ext = originalFileName.substring(dotIdx).toLowerCase();

            String savedFileName = "camps/" + System.currentTimeMillis() + "_" + (int)(Math.random() * 100000) + ext;

            if (BUCKET != null && !BUCKET.trim().isEmpty()) {
                // S3 업로드
                try (InputStream is = filePart.getInputStream()) {
                    S3Client s3 = S3Client.builder()
                            .region(Region.of(REGION))
                            .credentialsProvider(InstanceProfileCredentialsProvider.create())
                            .build();

                    s3.putObject(PutObjectRequest.builder()
                            .bucket(BUCKET)
                            .key(savedFileName)
                            .contentType(filePart.getContentType())
                            .contentLength(filePart.getSize())
                            .build(),
                            RequestBody.fromInputStream(is, filePart.getSize()));
                    s3.close();

                    imagePath = "https://" + BUCKET + ".s3." + REGION + ".amazonaws.com/" + savedFileName;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else {
                // 로컬 저장 (개발 환경)
                String uploadPath = getServletContext().getRealPath("/assets/img/camps");
                new File(uploadPath).mkdirs();
                String localFileName = savedFileName.replace("camps/", "");
                filePart.write(uploadPath + File.separator + localFileName);
                imagePath = "/assets/img/camps/" + localFileName;
            }
        }

        try (Connection conn = DBUtil.getConnection()) {
            String sql =
                "INSERT INTO camps (name, address, type, tags, price, image, status, description) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, name.trim());
                pstmt.setString(2, address.trim());
                pstmt.setString(3, type.trim());
                pstmt.setString(4, tags.trim());
                pstmt.setInt(5, price);
                pstmt.setString(6, imagePath);
                pstmt.setString(7, status.trim());
                pstmt.setString(8, description.trim());
                pstmt.executeUpdate();
            }

            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println(
                "<script>alert('캠핑장이 등록되었습니다.'); location.href='" + ctx + "/owner/dashboard.jsp';</script>"
            );
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<script>alert('DB 저장 중 오류 발생'); history.back();</script>");
        }
    }
}
