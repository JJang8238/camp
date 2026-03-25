package dto;

public class Match {
    private int id;
    private String location; // 캠핑장 장소 이름
    private String matchDate;
    
    public Match() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getMatchDate() { return matchDate; }
    public void setMatchDate(String matchDate) { this.matchDate = matchDate; }
}