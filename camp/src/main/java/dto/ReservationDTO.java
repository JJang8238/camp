package dto;

import java.sql.Timestamp;

public class ReservationDTO {
    private int id;
    private int userId;
    private int campId;
    private String campName;
    private String reserveDate;
    private int peopleCount;
    private String status;
    private Timestamp createdAt;
    private String orderId;
    private String paymentKey;
    private int amount;

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public int getUserId()                      { return userId; }
    public void setUserId(int userId)           { this.userId = userId; }

    public int getCampId()                      { return campId; }
    public void setCampId(int campId)           { this.campId = campId; }

    public String getCampName()                 { return campName; }
    public void setCampName(String campName)    { this.campName = campName; }

    public String getReserveDate()                      { return reserveDate; }
    public void setReserveDate(String reserveDate)      { this.reserveDate = reserveDate; }

    public int getPeopleCount()                         { return peopleCount; }
    public void setPeopleCount(int peopleCount)         { this.peopleCount = peopleCount; }

    public String getStatus()                   { return status; }
    public void setStatus(String status)        { this.status = status; }

    public Timestamp getCreatedAt()                     { return createdAt; }
    public void setCreatedAt(Timestamp createdAt)       { this.createdAt = createdAt; }

    public String getOrderId()                  { return orderId; }
    public void setOrderId(String orderId)      { this.orderId = orderId; }

    public String getPaymentKey()                       { return paymentKey; }
    public void setPaymentKey(String paymentKey)        { this.paymentKey = paymentKey; }

    public int getAmount()                      { return amount; }
    public void setAmount(int amount)           { this.amount = amount; }
}
