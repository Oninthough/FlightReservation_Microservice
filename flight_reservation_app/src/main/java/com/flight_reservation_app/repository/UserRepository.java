package com.flight_reservation_app.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.flight_reservation_app.entities.User;

public interface UserRepository extends JpaRepository<User, Long> {

	public User findByEmail(String email);

}
