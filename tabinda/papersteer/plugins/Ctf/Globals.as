﻿// ----------------------------------------------------------------------------
//
// OpenSteer - Action Script 3 Port
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

package tabinda.papersteer.plugins.Ctf
{
	import tabinda.papersteer.*;
	
	class Globals
	{
		public static  const HomeBaseCenter:Vector3D=new Vector3D(0,0,0);
		public const HomeBaseRadius:Number=1.5;

		public const MinStartRadius:Number=30;
		public const MaxStartRadius:Number=40;

		public const BrakingRate:Number=0.75;

		public static  const EvadeColor:uint=Colors.toHex(int(255.0 * 0.6),int(255.0 * 0.6),int(255.0 * 0.3));// annotation
		public static  const SeekColor:uint=Colors.toHex(int(255.0 * 0.3),int(255.0 * 0.6),int(255.0 * 0.6));// annotation
		public static  const ClearPathColor:uint=Colors.toHex(int(255.0 * 0.3),int(255.0 * 0.6),int(255.0 * 0.3));// annotation

		public const AvoidancePredictTimeMin:Number=0.9;
		public const AvoidancePredictTimeMax:Number=2;
		public static  var AvoidancePredictTime:Number=AvoidancePredictTimeMin;

		public static  var EnableAttackSeek:Boolean=true;// for testing (perhaps retain for UI control?)
		public static  var EnableAttackEvade:Boolean=true;// for testing (perhaps retain for UI control?)

		public static  var Seeker:CtfSeeker=null;

		// count the number of times the simulation has reset (e.g. for overnight runs)
		public static  var ResetCount:int=0;

		// ----------------------------------------------------------------------------
		// state for OpenSteerDemo PlugIn
		//
		// XXX consider moving this inside CtfPlugIn
		// XXX consider using STL (any advantage? consistency?)

		public static  var CtfSeeker:CtfSeeker=null;
		public static  var CtfEnemyCount:int=4;
		public static  var CtfEnemies:Array=new Array(CtfEnemyCount);
	}
}