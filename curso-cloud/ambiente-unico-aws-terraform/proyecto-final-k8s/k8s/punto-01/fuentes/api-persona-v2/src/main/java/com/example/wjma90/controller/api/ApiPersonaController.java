package com.example.wjma90.controller.api;

import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.wjma90.dto.RespuestaApi;
import com.example.wjma90.model.Persona;
import com.example.wjma90.service.PersonaService;

@RestController
@CrossOrigin
@RequestMapping("api/personas/")
public class ApiPersonaController {
	
	private static final Logger logger = LoggerFactory.getLogger(ApiPersonaController.class);

	@Autowired
	private PersonaService service;

	@GetMapping(value="rango/{edadMenor}/{edadMayor}", produces = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<List<Persona>> obtenerTodos(
			@PathVariable int edadMenor,
			@PathVariable int edadMayor){
		try {
			ResponseEntity<List<Persona>> rpta =  new ResponseEntity<List<Persona>>(service.obtenerPorRangoEdad(edadMenor, edadMayor), HttpStatus.OK);
			logger.info("[listar] Devolucion rango correcta");
			return rpta;
		}catch(Exception e) {
			logger.error("Error: ",e);
			return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}

	@GetMapping(value="/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<Persona> obtenerPorId(@PathVariable int id){
		try {
			HttpHeaders responseHeaders = new HttpHeaders();
			responseHeaders.add("x-example","myvalue");
			ResponseEntity<Persona> rpta = ResponseEntity.ok()
				.headers(responseHeaders)
				.body(service.obtenerPorId(id));
			logger.info("[listar] Devolucion por id correcta");
			return rpta;
		}catch(Exception e) {
			logger.error("Error: ",e);
			return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}
	
	@GetMapping(value="", produces = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<List<Persona>> obtenerTodos(){
		try {
			HttpHeaders responseHeaders = new HttpHeaders();
			responseHeaders.add("x-example","myvalue");
			ResponseEntity<List<Persona>> rpta = ResponseEntity.ok()
				.headers(responseHeaders)
				.body(service.listarTodos());
			// ResponseEntity<List<Persona>> rpta = new ResponseEntity<List<Persona>>(service.listarTodos(), HttpStatus.OK);
			logger.info("[listar] Devolucion correcta");
			return rpta;
		}catch(Exception e) {
			logger.error("Error: ",e);
			return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}

	@PostMapping(value="", produces = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<RespuestaApi> guardar(
			@RequestBody Persona persona){
		try {
			service.guardarDatos(persona);
			logger.info("Se guardo correctamente");
			return new ResponseEntity<RespuestaApi>(new RespuestaApi("OK",""), HttpStatus.OK);
		}catch(Exception e) {
			logger.error("Error: ",e);
			return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}
	
	@DeleteMapping(value="/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<RespuestaApi> eliminar(
			@PathVariable int id){
		try {
			service.eliminarDatos(id);
			logger.info("Se elimino correctamente");
			return new ResponseEntity<RespuestaApi>(new RespuestaApi("OK",""), HttpStatus.OK);
		}catch(Exception e) {
			logger.error("Error: ",e);
			return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}
}
