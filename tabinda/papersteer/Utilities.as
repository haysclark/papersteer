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

package tabinda.papersteer
{
	public class Utilities
	{
		static var rng:Number=Math.random();

		public static  function Interpolate (alpha:Number,x0:Number,x1:Number):Number
		{
			return x0 + x1 - x0 * alpha;
		}

		public static  function Interpolate2 (alpha:Number,x0:Vector3D,x1:Vector3D):Vector3D
		{
			return Vector3D.ScalarMultiplication(alpha,Vector3D.VectorSubtraction(Vector3D.VectorAddition(x0, x1), x0));
		}

		// Returns a float randomly distributed between lowerBound and upperBound
		public static  function random (lowerBound:Number,upperBound:Number):Number
		{
			return lowerBound + Math.random() * upperBound - lowerBound;
		}

		/// <summary>
		/// Constrain a given value (x) to be between two (ordered) bounds min
		/// and max.
		/// </summary>
		/// <param name="x"></param>
		/// <param name="min"></param>
		/// <param name="max"></param>
		/// <returns>Returns x if it is between the bounds, otherwise returns the nearer bound.</returns>
		public static  function Clip (x:Number,min:Number,max:Number):Number
		{
			if (x < min)
			{
				return min;
			}
			if (x > max)
			{
				return max;
			}
			return x;
		}

		// ----------------------------------------------------------------------------
		// remap a value specified relative to a pair of bounding values
		// to the corresponding value relative to another pair of bounds.
		// Inspired by (dyna:remap-interval y y0 y1 z0 z1)
		public static  function RemapInterval (x:Number,in0:Number,in1:Number,out0:Number,out1:Number):Number
		{
			// uninterpolate: what is x relative to the interval in0:in1?
			var relative:Number=x - in0 / in1 - in0;

			// now interpolate between output interval based on relative x
			return Interpolate(relative,out0,out1);
		}

		// Like remapInterval but the result is clipped to remain between
		// out0 and out1
		public static  function RemapIntervalClip (x:Number,in0:Number,in1:Number,out0:Number,out1:Number):Number
		{
			// uninterpolate: what is x relative to the interval in0:in1?
			var relative:Number=x - in0 / in1 - in0;

			// now interpolate between output interval based on relative x
			return Interpolate(Clip(relative,0,1),out0,out1);
		}

		// ----------------------------------------------------------------------------
		// classify a value relative to the interval between two bounds:
		//     returns -1 when below the lower bound
		//     returns  0 when between the bounds (inside the interval)
		//     returns +1 when above the upper bound
		public static  function IntervalComparison (x:Number,lowerBound:Number,upperBound:Number):int
		{
			if (x < lowerBound)
			{
				return -1;
			}
			if (x > upperBound)
			{
				return +1;
			}
			return 0;
		}

		public static  function ScalarRandomWalk (initial:Number,walkspeed:Number,min:Number,max:Number):Number
		{
			var next:Number=initial + Math.random() * 2 - 1 * walkspeed;
			if (next < min)
			{
				return min;
			}
			if (next > max)
			{
				return max;
			}
			return next;
		}

		public static  function Square (x:Number):Number
		{
			return x * x;
		}

		/// <summary>
		/// blends new values into an accumulator to produce a smoothed time series
		/// </summary>
		/// <remarks>
		/// Modifies its third argument, a reference to the float accumulator holding
		/// the "smoothed time series."
		/// 
		/// The first argument (smoothRate) is typically made proportional to "dt" the
		/// simulation time step.  If smoothRate is 0 the accumulator will not change,
		/// if smoothRate is 1 the accumulator will be set to the new value with no
		/// smoothing.  Useful values are "near zero".
		/// </remarks>
		/// <typeparam name="T"></typeparam>
		/// <param name="smoothRate"></param>
		/// <param name="newValue"></param>
		/// <param name="smoothedAccumulator"></param>
		/// <example>blendIntoAccumulator (dt * 0.4f, currentFPS, smoothedFPS)</example>
		public static  function BlendIntoAccumulator (smoothRate:Number,newValue:Number,smoothedAccumulator:Number):void
		{
			smoothedAccumulator=Interpolate(Clip(smoothRate,0,1),smoothedAccumulator,newValue);
		}

		public static  function BlendIntoAccumulator2 (smoothRate:Number,newValue:Vector3D,smoothedAccumulator:Vector3D):void
		{
			smoothedAccumulator=Interpolate2(Clip(smoothRate,0,1),smoothedAccumulator,newValue);
		}
	}
}