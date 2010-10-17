﻿// ----------------------------------------------------------------------------
//
// PaperSteer - Papervision3D Port of OpenSteer
// Port by Mohammad Haseeb aka M.H.A.Q.S.
// http://www.tabinda.net
//
// OpenSteer -- Steering Behaviors for Autonomous Characters
//
// Copyright (c) 2002-2003, Sony Computer Entertainment America
// Original author: Craig Reynolds <craig_reynolds@playstation.sony.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//
// ----------------------------------------------------------------------------

package tabinda.demo.plugins.Boids
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.text.TextField;
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.materials.special.Letter3DMaterial;
	import org.papervision3d.typography.Font3D;
	import org.papervision3d.typography.Text3D;
	
	import tabinda.demo.*;
	import tabinda.papersteer.*;

	public class BoidsPlugIn extends PlugIn
	{		
		public function BoidsPlugIn()
		{
			super();
			flock = new Vector.<Boid>();
		}

		public override function get Name():String 
		{ return "Boids";}

		public override function get SelectionOrderSortKey():Number
		{
			return -0.03; 
		}

		public override function Open():void
		{
			// make the database used to accelerate proximity queries
			cyclePD = -1;
			NextPD();

			// make default-sized flock
			population = 0;
			for (var i:int = 0; i < 20; i++) 
			{
				AddBoidToFlock();
			}

			// initialize camera
			Demo.Init3dCamera(Demo.SelectedVehicle);
			Demo.camera.Mode = CameraMode.Fixed;
			Demo.camera.FixedDistanceDistance = Demo.CameraTargetDistance;
			Demo.camera.FixedDistanceVerticalOffset = 0;
			Demo.camera.LookDownDistance = 20;
			Demo.camera.AimLeadTime = 0.5;
			Demo.camera.PovOffset.x =0;
            Demo.camera.PovOffset.y = 0.5;
            Demo.camera.PovOffset.z = -2;
		}

		public override function Update(currentTime:Number, elapsedTime:Number):void
		{
			// update flock simulation for each boid
			for (var i:int = 0; i < flock.length; i++)
			{
				flock[i].Update(currentTime, elapsedTime);
			}
		}

		public override function Redraw(currentTime:Number, elapsedTime:Number):void
		{
			// selected vehicle (user can mouse click to select another)
			var selected:IVehicle = Demo.SelectedVehicle;

			// vehicle nearest mouse (to be highlighted)
			var nearMouse:IVehicle = null;// Demo.vehicleNearestToMouse();

			// update camera
			Demo.UpdateCamera(currentTime, elapsedTime, selected);

			// draw each boid in flock
			for (var i:int = 0; i < flock.length; i++)
			{
				flock[i].Draw();
			}

			// highlight vehicle nearest mouse
			Demo.DrawCircleHighlightOnVehicle(nearMouse, 1, Colors.LightGray);

			// highlight selected vehicle
			Demo.DrawCircleHighlightOnVehicle(selected, 1, Colors.Gray);

			// display status in the upper left corner of the window
			var stats:String = new String();
			stats = "[F1/F2] " + population + " boids";
			stats += "\n[F3] PD type: ";
			switch (cyclePD)
			{
				case 0: stats +="LQ bin lattice"; break;
				case 1: stats += "brute force"; break;
			}
			stats +="\n[F4] Boundary: ";
			switch (Boid.boundaryCondition)
			{
				case 0: stats +="steer back when outside"; break;
				case 1: stats +="wrap around (teleport)"; break;
			}
			var screenLocation:Vector3 = new Vector3(15, 50, 0);
			Drawing.Draw2dTextAt2dLocation(stats, screenLocation, Colors.LightGray);
		}

		public override function Close():void
		{
			// delete each member of the flock
			while (population > 0)
			{
				RemoveBoidFromFlock();
			}
			
			//TODO: Remove scene object once the plugin closes
			//Demo.scene.objects.splice(0);
			
			// delete the proximity database
			pd = null;
		}

		public override function Reset():void
		{
			// reset each boid in flock
			for (var i:int = 0; i < flock.length; i++) flock[i].Reset();

			// reset camera position
			Demo.Position3dCamera(Demo.SelectedVehicle);

			// make camera jump immediately to new position
			Demo.camera.DoNotSmoothNextMove();
		}

		// for purposes of demonstration, allow cycling through various
		// types of proximity databases.  this routine is called when the
		// Demo user pushes a function key.
		public function NextPD():void
		{
			// save pointer to old PD
			var oldPD:IProximityDatabase = pd;

			// allocate new PD
			const totalPD:int = 2;
			switch (cyclePD = (cyclePD + 1) % totalPD)
			{
			case 0:
				{
					var center:Vector3 = Vector3.Zero;
					var div:Number = 10.0;
					var divisions:Vector3 = new Vector3(div, div, div);
					var diameter:Number = Boid.worldRadius * 1.1 * 2;
					var dimensions:Vector3 = new Vector3(diameter, diameter, diameter);
					pd = new LQProximityDatabase(center, dimensions, divisions);
					break;
				}
			case 1:
				{
					pd = new BruteForceProximityDatabase();
					break;
				}
			}

			// switch each boid to new PD
			for (var i:int = 0; i < flock.length; i++)
			{
				flock[i].NewPD(pd);
			}

			// delete old PD (if any)
			oldPD = null;
		}

		public override function HandleFunctionKeys(key:uint):void
		{
			switch (key)
			{
			case (Keyboard.F1): AddBoidToFlock(); break;
			case (Keyboard.F2): RemoveBoidFromFlock(); break;
			case (Keyboard.F3): NextPD(); break;
			case (Keyboard.F4): Boid.NextBoundaryCondition(); break;
			}
		}

		public override function PrintMiniHelpForFunctionKeys():void
		{
			var message:String = "Function keys handled by \n" + "\"" + Name + "\"" + ":";
			Demo.printMessage (message);
			Demo.printMessage ("  F1     add a boid to the flock.");
			Demo.printMessage ("  F2     remove a boid from the flock.");
			Demo.printMessage ("  F3     use next proximity database.");
			Demo.printMessage ("  F4     next flock boundary condition.");
			Demo.printMessage ("");
		}

		public function AddBoidToFlock():void
		{
			population++;
			var boid:Boid = new Boid(pd);
			flock.push(boid);
			Demo.scene.addChild(boid.BoidMesh);
			
			if (population == 1)
			{
				Demo.SelectedVehicle = boid;
			}
		}

		public function RemoveBoidFromFlock():void
		{
			if (population > 0)
			{
				// save a pointer to the last boid, then remove it from the flock
				population--;
				var boid:Boid = flock[population];
				flock.splice(population, 1);
				Demo.scene.removeChild(boid.BoidMesh);

				// if it is Demo's selected vehicle, unselect it
				if (boid == Demo.SelectedVehicle)
				{
					Demo.SelectedVehicle = null;
				}

				// delete the Boid
				boid = null;
			}
		}

		// return an AVGroup containing each boid of the flock
		public override function get Vehicles():Vector.<IVehicle>
		{
			var vehicles:Vector.<IVehicle> = Vector.<IVehicle>(flock);
			return vehicles;
		}
		
		// flock: a group (STL vector) of pointers to all boids
		public var flock:Vector.<Boid>;

		// pointer to database used to accelerate proximity queries
		public var pd:IProximityDatabase;

		// keep track of current flock size
		public var population:int;

		// which of the various proximity databases is currently in use
		public var cyclePD:int;
	}
}
