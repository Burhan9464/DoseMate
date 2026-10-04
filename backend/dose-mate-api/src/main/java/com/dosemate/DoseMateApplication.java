package com.dosemate;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class DoseMateApplication {

    public static void main(String[] args) {
        SpringApplication.run(DoseMateApplication.class, args);
    }
}
