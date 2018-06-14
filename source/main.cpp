/*
 * =====================================================================================
 *
 *       Filename:  main.cpp
 *
 *    Description:
 *
 *        Created:  13/12/2014 20:49:00
 *
 *         Author:  Quentin Bazin, <quent42340@gmail.com>
 *
 * =====================================================================================
 */
#include <iostream>

#include "Application.hpp"
#include "Exception.hpp"
#include "SDLLoader.hpp"

int main(int argc, char **argv) {
	SDLLoader sdlLoader;
	sdlLoader.load();

	Application app(argc, argv);
	app.run();

	return 0;
}

