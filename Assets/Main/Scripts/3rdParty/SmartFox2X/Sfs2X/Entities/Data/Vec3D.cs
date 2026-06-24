using System;

namespace Sfs2X.Entities.Data
{
  public class Vec3D
  {
    private float fx;
    private float fy;
    private float fz;
    private int ix;
    private int iy;
    private int iz;
    private bool useFloat;

    public static Vec3D fromArray(object array)
    {
      if (array is SFSArrayLite)
      {
        SFSArrayLite sfsArrayLite = array as SFSArrayLite;
        object elementAt1 = sfsArrayLite.GetElementAt(0);
        object elementAt2 = sfsArrayLite.GetElementAt(1);
        object obj = sfsArrayLite.Size() > 2 ? sfsArrayLite.GetElementAt(2) : 0;
        if (elementAt1 is double)
          array = new[]
          {
            Convert.ToSingle(elementAt1),
            Convert.ToSingle(elementAt2),
            Convert.ToSingle(obj)
          };
        else
          array = new[]
          {
            Convert.ToInt32(elementAt1),
            Convert.ToInt32(elementAt2),
            Convert.ToInt32(obj)
          };
      }
      if (array is int[])
        return fromIntArray((int[]) array);
      if (array is float[])
        return fromFloatArray((float[]) array);
      throw new ArgumentException("Invalid Array Type, cannot convert to Vec3D!");
    }

    private static Vec3D fromIntArray(int[] array)
    {
      if (array.Length != 3)
        throw new ArgumentException("Wrong array size. Vec3D requires an array with 3 parameters (x,y,z)");
      return new Vec3D(array[0], array[1], array[2]);
    }

    private static Vec3D fromFloatArray(float[] array)
    {
      if (array.Length != 3)
        throw new ArgumentException("Wrong array size. Vec3D requires an array with 3 parameters (x,y,z)");
      return new Vec3D(array[0], array[1], array[2]);
    }

    private Vec3D()
    {
    }

    public Vec3D(int px, int py, int pz)
    {
      ix = px;
      iy = py;
      iz = pz;
      useFloat = false;
    }

    public Vec3D(int px, int py)
      : this(px, py, 0)
    {
    }

    public Vec3D(float px, float py, float pz)
    {
      fx = px;
      fy = py;
      fz = pz;
      useFloat = true;
    }

    public Vec3D(float px, float py)
      : this(px, py, 0.0f)
    {
    }

    public bool IsFloat()
    {
      return useFloat;
    }

    public float FloatX => fx;

    public float FloatY => fy;

    public float FloatZ => fz;

    public int IntX => ix;

    public int IntY => iy;

    public int IntZ => iz;

    public int[] ToIntArray()
    {
      return new[]{ ix, iy, iz };
    }

    public float[] ToFloatArray()
    {
      return new[]{ fx, fy, fz };
    }

    public override string ToString()
    {
      return IsFloat() ? $"({(object) fx},{(object) fy},{(object) fz})" : $"({(object) ix},{(object) iy},{(object) iz})";
    }
  }
}





