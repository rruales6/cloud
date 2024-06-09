package com.example.wjma90.dao;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.wjma90.model.Persona;

public interface PersonaDAO extends JpaRepository<Persona, Integer>{

	@Query("SELECT s FROM Persona s WHERE (s.edad BETWEEN :edadMenor AND :edadMayor)")
	public List<Persona> obtenerPorRangoEdad(
			@Param("edadMenor") int edadMenor,
			@Param("edadMayor") int edadMayor);
}
