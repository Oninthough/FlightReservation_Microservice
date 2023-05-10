package com.flight_reservation_app.service;

import com.flight_reservation_app.dto.EmailDetails;
import com.flight_reservation_app.dto.ReservationDto;
import com.flight_reservation_app.entities.Reservation;

public interface ReservationService {

	Reservation bookFlight(ReservationDto request,EmailDetails details);

}
