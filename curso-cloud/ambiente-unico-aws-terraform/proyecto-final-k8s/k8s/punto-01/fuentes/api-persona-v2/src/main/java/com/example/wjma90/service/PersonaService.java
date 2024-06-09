package com.example.wjma90.service;

import java.util.List;

import com.example.wjma90.model.Persona;

public interface PersonaService {

	List<Persona> obtenerPorRangoEdad(
			int edadMenor,
			int edadMayor);
	
	List<Persona> listarTodos();
	Persona obtenerPorId(int idPersona);
	void guardarDatos(Persona persona);
	void eliminarDatos(int personaId);
}
