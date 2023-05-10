package com.checkin.implementation;

import org.springframework.web.bind.annotation.RequestBody;

import com.checkin.implementation.dto.CheckinDto;
import com.checkin.implementation.dto.Reservation;

public interface ReservationRestfulClient {
	public Reservation findReservation(Long id);

	public Reservation generateBoardingPass(CheckinDto chek);

}
