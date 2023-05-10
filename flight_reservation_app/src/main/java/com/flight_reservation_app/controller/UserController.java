package com.flight_reservation_app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.flight_reservation_app.entities.User;
import com.flight_reservation_app.repository.UserRepository;

@Controller
public class UserController {
	@Autowired
	private UserRepository userRepo;
	
	@RequestMapping("/showlogin")
	public String showloginpage()
	{
		return "login/loginjsp";
	}
	
	@RequestMapping("/showReg")
	public String showReg()
	{
		return "login/showReg";
	}

	@RequestMapping("/saveReg")
	public String saveRegistration(@ModelAttribute("user") User user)
	{
		userRepo.save(user);
		return "login/loginjsp";
	}
	
	@RequestMapping("/newLog")
	public String verifyLogin(@RequestParam("emailId") String email, @RequestParam("password") String password, Model model)
	{
		User user1 = userRepo.findByEmail(email);
		if(user1!=null)
		{
		if(user1.getEmail().equals(email) && user1.getPassword().equals(password))
			return "findFlights";
		else
		{
			model.addAttribute("msg", "Invalid credentials");
			return "login/loginjsp";
		}
		}
		else
		{
			model.addAttribute("msg", "Invalid credentials");
			return "login/loginjsp";
		}
			
			
	}
	
	
}
