/**
 * Created by Adrian on 04.06.2016.
 */
public interface HotelAPI {

    void addCustomer(String name, String lastName, String address);

    void deleteCustomer(int customerID);

    void addRoom(int Capacity, int numberOfBeds, boolean isBalcony, String roomType, double price);

    void deleteRoom(int roomID);

    void reserve(int customerID, int roomID, String startDate, String endDate);

    void cancelReservation(int reservationID);

    void hireStaff(String name, String lastName, String address, String position);

    void fireStaff(int staffID);

    boolean isRoomFree(int roomID, String startDate, String endDate);

    double showBill(int reservationID);

}
