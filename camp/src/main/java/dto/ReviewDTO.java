package dto;

public class ReviewDTO {
    private int    id;
    private String title;
    private String summary;
    private String content;
    private String category;
    private String thumbnail;
    private int    viewCount;
    private String status;
    private String createdAt;
    private String updatedAt;

    public int    getId()                       { return id; }
    public void   setId(int id)                 { this.id = id; }

    public String getTitle()                    { return title; }
    public void   setTitle(String title)        { this.title = title; }

    public String getSummary()                  { return summary; }
    public void   setSummary(String summary)    { this.summary = summary; }

    public String getContent()                  { return content; }
    public void   setContent(String content)    { this.content = content; }

    public String getCategory()                 { return category; }
    public void   setCategory(String category)  { this.category = category; }

    public String getThumbnail()                        { return thumbnail; }
    public void   setThumbnail(String thumbnail)        { this.thumbnail = thumbnail; }

    public int    getViewCount()                        { return viewCount; }
    public void   setViewCount(int viewCount)           { this.viewCount = viewCount; }

    public String getStatus()                   { return status; }
    public void   setStatus(String status)      { this.status = status; }

    public String getCreatedAt()                        { return createdAt; }
    public void   setCreatedAt(String createdAt)        { this.createdAt = createdAt; }

    public String getUpdatedAt()                        { return updatedAt; }
    public void   setUpdatedAt(String updatedAt)        { this.updatedAt = updatedAt; }
}
