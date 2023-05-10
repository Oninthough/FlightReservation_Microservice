package com.flight_reservation_app.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.flight_reservation_app.entities.Passanger;

public interface PassangerRepository extends JpaRepository<Passanger, Long> {

}
