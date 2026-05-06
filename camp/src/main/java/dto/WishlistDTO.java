package dto;

public class WishlistDTO {
    private int    id;
    private int    campId;
    private String createdAt;

    // camps 테이블 JOIN 데이터
    private String campName;
    private String campAddress;
    private String campType;
    private String campTags;
    private int    campPrice;
    private String campImage;
    private String campStatus;

    public int    getId()                           { return id; }
    public void   setId(int id)                     { this.id = id; }

    public int    getCampId()                       { return campId; }
    public void   setCampId(int campId)             { this.campId = campId; }

    public String getCreatedAt()                    { return createdAt; }
    public void   setCreatedAt(String createdAt)    { this.createdAt = createdAt; }

    public String getCampName()                     { return campName; }
    public void   setCampName(String campName)      { this.campName = campName; }

    public String getCampAddress()                          { return campAddress; }
    public void   setCampAddress(String campAddress)        { this.campAddress = campAddress; }

    public String getCampType()                     { return campType; }
    public void   setCampType(String campType)      { this.campType = campType; }

    public String getCampTags()                     { return campTags; }
    public void   setCampTags(String campTags)      { this.campTags = campTags; }

    public int    getCampPrice()                    { return campPrice; }
    public void   setCampPrice(int campPrice)       { this.campPrice = campPrice; }

    public String getCampImage()                    { return campImage; }
    public void   setCampImage(String campImage)    { this.campImage = campImage; }

    public String getCampStatus()                           { return campStatus; }
    public void   setCampStatus(String campStatus)          { this.campStatus = campStatus; }
}
