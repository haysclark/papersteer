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
using System.Collections.Specialized;
using System.Collections.Generic;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework;*/

package tabinda.papersteer.plugins.MapDrive
{
	public class TerrainMap
	{
		public function TerrainMap (c:Vector3,x:Number,z:Number,r:int)
		{
			center=c;
			xSize=x;
			zSize=z;
			resolution=r;
			outsideValue=false;

			map=new Array(resolution * resolution);
			for (var i:int=0; i < resolution * resolution; i++)
			{
				map[i]=false;
			}
		}

		// clear the map (to false)
		public function Clear ():void
		{
			for (var i:int=0; i < resolution; i++)
			{
				for (var j:int=0; j < resolution; j++)
				{
					SetMapBit (i,j,false);
				}
			}

		}// get and set a bit based on 2d integer map index
		public function GetMapBit (i:int,j:int):Boolean
		{
			return map[MapAddress(i,j)];
		}

		public function SetMapBit (i:int,j:int,value:Boolean):Boolean
		{
			return map[MapAddress(i,j)]=value;
		}

		// get a value based on a position in 3d world space
		public function GetMapValue (point:Vector3):Boolean
		{
			var local:Vector3=point - center;
			local.Y=0;
			var localXZ:Vector3=local;

			var hxs:Number=xSize / 2;
			var hzs:Number=zSize / 2;

			var x:Number=localXZ.X;
			var z:Number=localXZ.Z;

			var isOut:Boolean=x > + hxs || x < - hxs || z > + hzs || z < - hzs;

			if (isOut)
			{
				return outsideValue;
			}
			else
			{
				var r:Number=Number(resolution);// prevent VC7.1 warning
				var i:int=int(Utilities.RemapInterval(x,- hxs,hxs,0.0,r));
				var j:int=int(Utilities.RemapInterval(z,- hzs,hzs,0.0,r));
				return GetMapBit(i,j);
			}
		}

		public function xxxDrawMap ():void
		{
			var xs:Number=xSize / Number(resolution);
			var zs:Number=zSize / Number(resolution);
			var alongRow:Vector3=new Vector3(xs,0,0);
			var nextRow:Vector3=new Vector3(- xSize,0,zs);
			var g:Vector3=new Vector3(xSize - xs / -2,0,zSize - zs / -2);
			g+= center;
			for (var j:int=0; j < resolution; j++)
			{
				for (var i:int=0; i < resolution; i++)
				{
					if (GetMapBit(i,j))
					{
						// spikes
						// Vector3 spikeTop (0, 5.0f, 0);
						// drawLine (g, g+spikeTop, gWhite);

						// squares
						var rockHeight:Number=0;
						var v1:Vector3=new Vector3(+ xs / 2,rockHeight,+ zs / 2);
						var v2:Vector3=new Vector3(+ xs / 2,rockHeight,- zs / 2);
						var v3:Vector3=new Vector3(- xs / 2,rockHeight,- zs / 2);
						var v4:Vector3=new Vector3(- xs / 2,rockHeight,+ zs / 2);
						// Vector3 redRockColor (0.6f, 0.1f, 0.0f);
						var orangeRockColor:Color=new Color(int(255.0 * 0.5),int(255.0 * 0.2),int(255.0 * 0.0));
						Drawing.DrawQuadrangle (g + v1,g + v2,g + v3,g + v4,orangeRockColor);

						// pyramids
						// Vector3 top (0, xs/2, 0);
						// Vector3 redRockColor (0.6f, 0.1f, 0.0f);
						// Vector3 orangeRockColor (0.5f, 0.2f, 0.0f);
						// drawTriangle (g+v1, g+v2, g+top, redRockColor);
						// drawTriangle (g+v2, g+v3, g+top, orangeRockColor);
						// drawTriangle (g+v3, g+v4, g+top, redRockColor);
						// drawTriangle (g+v4, g+v1, g+top, orangeRockColor);
					}
					g+= alongRow;
				}
				g+= nextRow;
			}
		}

		public function MinSpacing ():Number
		{
			return Math.min(xSize,zSize) / Number(resolution);
		}

		// used to detect if vehicle body is on any obstacles
		public function ScanLocalXZRectangle (localSpace:ILocalSpace,xMin:Number,xMax:Number,zMin:Number,zMax:Number):Boolean
		{
			var spacing:Number=MinSpacing() / 2;

			for (var x:Number=xMin; x < xMax; x+= spacing)
			{
				for (var z:Number=zMin; z < zMax; z+= spacing)
				{
					var sample:Vector3=new Vector3(x,0,z);
					var global:Vector3=localSpace.GlobalizePosition(sample);
					if (GetMapValue(global))
					{
						return true;
					}
				}
			}
			return false;
		}

		// Scans along a ray (directed line segment) on the XZ plane, sampling
		// the map for a "true" cell.  Returns the index of the first sample
		// that gets a "hit", or zero if no hits found.
		public function ScanXZray (origin:Vector3,sampleSpacing:Vector3,sampleCount:int):int
		{
			var samplePoint:Vector3=origin;

			for (var i:int=1; i <= sampleCount; i++)
			{
				samplePoint+= sampleSpacing;
				if (GetMapValue(samplePoint))
				{
					return i;
				}
			}

			return 0;
		}

		public function Cellwidth ():int
		{
			return resolution;
		}// xxx cwr
		public function Cellheight ():int
		{
			return resolution;
		}// xxx cwr
		public function IsPassable (point:Vector3):Boolean
		{
			return ! GetMapValue(point);
		}

		public var center:Vector3;
		public var xSize:Number;
		public var zSize:Number;
		public var resolution:int;

		public var outsideValue:Boolean;

		function MapAddress (i:int,j:int):int
		{
			return i + j * resolution;
		}

		var map:Array;
	}
}