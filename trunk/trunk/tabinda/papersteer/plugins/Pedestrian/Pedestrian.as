﻿// Copyright (c) 2002-2003, Sony Computer Entertainment America
// Copyright (c) 2002-2003, Craig Reynolds <craig_reynolds@playstation.sony.com>
// Copyright (C) 2007 Bjoern Graf <bjoern.graf@gmx.net>
// Copyright (C) 2007 Michael Coles <michael@digini.com>
// All rights reserved.
//
// This software is licensed as described in the file license.txt, which
// you should have received as part of this distribution. The terms
// are also available at http://www.codeplex.com/SharpSteer/Project/License.aspx.

/*using System;
using System.Collections.Generic;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework;*/

package tabinda.papersteer.plugins.Pedestrian
{
	//using ProximityDatabase = IProximityDatabase<IVehicle>;
	//using ProximityToken = ITokenForProximityDatabase<IVehicle>;

	public class Pedestrian extends SimpleVehicle
	{
		var trail:Trail;

		// called when steerToFollowPath decides steering is required
		public function AnnotatePathFollowing(future:Vector3, onPath:Vector3, target:Vector3, outside:Number):void
		{
			var yellow:Color = Color.Yellow;
			var lightOrange:Color = new Color(int(255.0 * 1.0), int(255.0 * 0.5), 0);
			var darkOrange:Color = new Color(int(255.0 * 0.6), int(255.0 * 0.3), 0);
			var yellowOrange:Color = new Color(int(255.0 * 1.0), int(255.0 * 0.75), 0);

			// draw line from our position to our predicted future position
			annotation.Line(Position, future, yellow);

			// draw line from our position to our steering target on the path
			annotation.Line(Position, target, Color.Orange);

			// draw a two-toned line between the future test point and its
			// projection onto the path, the change from dark to light color
			// indicates the boundary of the tube.
            var boundaryOffset:Vector3 = (onPath - future);
            boundaryOffset.Normalize();
            boundaryOffset *= outside;
			var onPathBoundary:Vector3 = future + boundaryOffset;
			annotation.Line(onPath, onPathBoundary, darkOrange);
			annotation.Line(onPathBoundary, future, lightOrange);
		}

		// called when steerToAvoidCloseNeighbors decides steering is required
		// (parameter names commented out to prevent compiler warning from "-W")
		public function AnnotateAvoidCloseNeighbor(other:IVehicle, additionalDistance:Number):void
		{
			// draw the word "Ouch!" above colliding vehicles
           var headOn:Boolean = Vector3.Dot(Forward, other.Forward) < 0;
			var green:Color = new Color(int(255.0 * 0.4), int(255.0 * 0.8), int(255.0 * 0.1));
			var red:Color = new Color((int(255.0 * 1), int(255.0 * 0.1), 0));
			var color:Color = headOn ? red : green;
			var text:String = headOn ? "OUCH!" : "pardon me";
			var location:Vector3 = Position + new Vector3(0, 0.5, 0);
			if (annotation.IsEnabled)
				Drawing.Draw2dTextAt3dLocation(text, location, color);
		}

		// (parameter names commented out to prevent compiler warning from "-W")
		public function AnnotateAvoidNeighbor(threat:IVehicle, steer:Number, ourFuture:Vector3, threatFuture:Vector3):void
		{
			var green:Color = new Color(int(255.0 * 0.15), int(255.0 * 0.6), 0);

			annotation.Line(Position, ourFuture, green);
			annotation.Line(threat.Position, threatFuture, green);
			annotation.Line(ourFuture, threatFuture, Color.Red);
			annotation.CircleXZ(Radius, ourFuture, green, 12);
			annotation.CircleXZ(Radius, threatFuture, green, 12);
		}

		// xxx perhaps this should be a call to a general purpose annotation for
		// xxx "local xxx axis aligned box in XZ plane" -- same code in in
		// xxx CaptureTheFlag.cpp
		public function AnnotateAvoidObstacle(minDistanceToCollision:Number):void
		{
			var boxSide:Vector3 = Side * Radius;
			var boxFront:Vector3 = Forward * minDistanceToCollision;
			var FR:Vector3 = Position + boxFront - boxSide;
			var FL:Vector3 = Position + boxFront + boxSide;
			var BR:Vector3 = Position - boxSide;
			var BL:Vector3 = Position + boxSide;
			annotation.Line(FR, FL, Color.White);
			annotation.Line(FL, BL, Color.White);
			annotation.Line(BL, BR, Color.White);
			annotation.Line(BR, FR, Color.White);
		}

		// constructor
		public function Pedestrian(pd:ProximityDatabase)
		{
			// allocate a token for this boid in the proximity database
			proximityToken = null;
			NewPD(pd);

			// reset Pedestrian state
			Reset();
		}

		// reset all instance state
		public override function Reset():void
		{
			// reset the vehicle 
			super.Reset();

			// max speed and max steering force (maneuverability) 
			MaxSpeed = 2.0;
			MaxForce = 8.0;

			// initially stopped
			Speed = 0;

			// size of bounding sphere, for obstacle avoidance, etc.
			Radius = 0.5; // width = 0.7, add 0.3 margin, take half

			// set the path for this Pedestrian to follow
			path = Globals.GetTestPath();

			// set initial position
			// (random point on path + random horizontal offset)
			var d:Number = path.TotalPathLength * Utilities.Random();
			var r:Number = path.radius;
			var randomOffset:Vector3 = Vector3Helpers.RandomVectorOnUnitRadiusXZDisk() * r;
			Position = (path.MapPathDistanceToPoint(d) + randomOffset);

			// randomize 2D heading
			RandomizeHeadingOnXZPlane();

			// pick a random direction for path following (upstream or downstream)
			pathDirection = (Utilities.Random() > 0.5) ? -1 : +1;

			// trail parameters: 3 seconds with 60 points along the trail
			trail = new Trail(3, 60);

			// notify proximity database that our position has changed
			if (proximityToken != null) proximityToken.UpdateForNewPosition(Position);
		}

		// per frame simulation update
		public function Update(currentTime:Number, elapsedTime:Number):void
		{
			// apply steering force to our momentum
			ApplySteeringForce(DetermineCombinedSteering(elapsedTime), elapsedTime);

			// reverse direction when we reach an endpoint
			if (Globals.UseDirectedPathFollowing)
			{
				if (Vector3.Distance(Position, Globals.Endpoint0) < path.radius)
				{
					pathDirection = +1;
					annotation.CircleXZ(path.radius, Globals.Endpoint0, Color.DarkRed, 20);
				}
				if (Vector3.Distance(Position, Globals.Endpoint1) < path.radius)
				{
					pathDirection = -1;
					annotation.CircleXZ(path.radius, Globals.Endpoint1, Color.DarkRed, 20);
				}
			}

			// annotation
			annotation.VelocityAcceleration(this, 5, 0);
			trail.Record(currentTime, Position);

			// notify proximity database that our position has changed
			proximityToken.UpdateForNewPosition(Position);
		}

		// compute combined steering force: move forward, avoid obstacles
		// or neighbors if needed, otherwise follow the path and wander
		public function DetermineCombinedSteering(elapsedTime:Number):Vector3
		{
			// move forward
			var steeringForce:Vector3 = Forward;

			// probability that a lower priority behavior will be given a
			// chance to "drive" even if a higher priority behavior might
			// otherwise be triggered.
			const leakThrough:Number = 0.1;

			// determine if obstacle avoidance is required
			var obstacleAvoidance:Vector3 = Vector3.Zero;
			if (leakThrough < Utilities.Random())
			{
				const oTime:Number = 6; // minTimeToCollision = 6 seconds
				obstacleAvoidance = SteerToAvoidObstacles(oTime, Globals.Obstacles);
			}

			// if obstacle avoidance is needed, do it
			if (obstacleAvoidance != Vector3.Zero)
			{
				steeringForce += obstacleAvoidance;
			}
			else
			{
				// otherwise consider avoiding collisions with others
				var collisionAvoidance:Vector3 = Vector3.Zero;
				const caLeadTime:Number = 3;

				// find all neighbors within maxRadius using proximity database
				// (radius is largest distance between vehicles traveling head-on
				// where a collision is possible within caLeadTime seconds.)
				var maxRadius:Number = caLeadTime * MaxSpeed * 2;
				neighbors.Clear();
				proximityToken.FindNeighbors(Position, maxRadius, neighbors);

				if (neighbors.Count > 0 && leakThrough < Utilities.Random())
					collisionAvoidance = SteerToAvoidNeighbors(caLeadTime, neighbors) * 10;

				// if collision avoidance is needed, do it
				if (collisionAvoidance != Vector3.Zero)
				{
					steeringForce += collisionAvoidance;
				}
				else
				{
					// add in wander component (according to user switch)
					if (Globals.WanderSwitch)
						steeringForce += SteerForWander(elapsedTime);

					// do (interactively) selected type of path following
					const pfLeadTime:Number = 3;
					var pathFollow:Vector3 =
						(Globals.UseDirectedPathFollowing ?
						 SteerToFollowPath(pathDirection, pfLeadTime, path) :
						 SteerToStayOnPath(pfLeadTime, path));

					// add in to steeringForce
					steeringForce += pathFollow * 0.5;
				}
			}

			// return steering constrained to global XZ "ground" plane
            steeringForce.Y = 0;
			return steeringForce;
		}


		// draw this pedestrian into scene
		public function Draw():void
		{
			Drawing.DrawBasic2dCircularVehicle(this, Color.Gray);
			trail.Draw(Annotation.drawer);
		}

		// switch to new proximity database -- just for demo purposes
		public function NewPD(pd:ProximityDatabase ):void
		{
			// delete this boid's token in the old proximity database
			if (proximityToken != null)
			{
				proximityToken.Dispose();
				proximityToken = null;
			}

			// allocate a token for this boid in the proximity database
			proximityToken = pd.AllocateToken(this);
		}

		// a pointer to this boid's interface object for the proximity database
		var proximityToken:ProximityToken;

		// allocate one and share amoung instances just to save memory usage
		// (change to per-instance allocation to be more MP-safe)
		//static List<IVehicle> neighbors = new List<IVehicle>();
		static var neighbors:Array = new Array();

		// path to be followed by this pedestrian
		// XXX Ideally this should be a generic Pathway, but we use the
		// XXX getTotalPathLength and radius methods (currently defined only
		// XXX on PolylinePathway) to set random initial positions.  Could
		// XXX there be a "random position inside path" method on Pathway?
		var path:PolylinePathway ;

		// direction for path following (upstream or downstream)
		var  pathDirection:int;
	}
}
