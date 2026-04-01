package dto;

public class Product {
    // 1. 공통 및 캠핑장 전용 필드 추가
    private int id;             // 고유 ID
    private String name;        // 이름 (용품/캠핑장 공통)
    private String address;     // 캠핑장 주소
    private String type;        // 숙소 유형 (펜션, 글램핑 등)
    private String tags;        // 캠핑장 태그 (#물놀이 등)
    private int price;          // 가격 (용품/캠핑장 공통)
    private String image;       // 기존 중고 용품 이미지 경로 필드
    private String imageUrl;    // 캠핑장 전용 이미지 경로 필드
    private int sellerId;       //판매자 정보
    private String description; //상품 설명
    private String category;    //상품 카테고리
    private String location;	//거래 위치
    private String createdAt;	//등록시간
    private boolean recent;
    // 기본 생성자
    public Product() {}

    // 2. Getter & Setter 메서드
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getTags() {
        return tags;
    }

    public void setTags(String tags) {
        this.tags = tags;
    }

    public int getPrice() {
        return price;
    }

    public void setPrice(int price) {
        this.price = price;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
    
    public int getSellerId() {
        return sellerId;
    }

    public void setSellerId(int sellerId) {
        this.sellerId = sellerId;
    }
    
    public String getDescription() { 
    	return description; 
    }
    
    public void setDescription(String description) { 
    	this.description = description; 
    }
    
    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
    
    public boolean isRecent() {
        return recent;
    }

    public void setRecent(boolean recent) {
        this.recent = recent;
    }
}