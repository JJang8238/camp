package dto;

public class EventDetail {
    private int postId;
    private String startDate;
    private String endDate;
    private String eventStatus;
    private String applyUrl;
    private String couponCode;
    private Integer maxParticipants;
    private String winnerAnnounceAt;

    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }

    public String getStartDate() { return startDate; }
    public void setStartDate(String startDate) { this.startDate = startDate; }

    public String getEndDate() { return endDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }

    public String getEventStatus() { return eventStatus; }
    public void setEventStatus(String eventStatus) { this.eventStatus = eventStatus; }

    public String getApplyUrl() { return applyUrl; }
    public void setApplyUrl(String applyUrl) { this.applyUrl = applyUrl; }

    public String getCouponCode() { return couponCode; }
    public void setCouponCode(String couponCode) { this.couponCode = couponCode; }

    public Integer getMaxParticipants() { return maxParticipants; }
    public void setMaxParticipants(Integer maxParticipants) { this.maxParticipants = maxParticipants; }

    public String getWinnerAnnounceAt() { return winnerAnnounceAt; }
    public void setWinnerAnnounceAt(String winnerAnnounceAt) { this.winnerAnnounceAt = winnerAnnounceAt; }
}