# https://github.com/SciRuby/nmatrix/wiki/Getting-started
require "alg/math/MtxOp"

class LinearAlgebra
  # Build-up Upper Triangular Matrix with order <n>
  def LinearAlgebra.newUTriMtx(n, d=1)
    m = zeroMtx(n,n)
    n.times do |ri|
      (ri...n).each do |ci|
        m[ri][ci]=d
      end
    end
    m
  end
  
  # Build-up Lower Triangular Matrix with order <n>
  def LinearAlgebra.newLTriMtx(n, d=1)
    m = zeroMtx(n,n)
    n.times do |ri|
      (0..ri).each do |ci|
        m[ri][ci]=d
      end
    end
    m
  end
  
  # Translation from Array to Matrix
  #
  # Argument
  #   * ary: Input array
  # Return
  #   * Matrix object
  def LinearAlgebra.A2M(ary,d=0)
    m = LinearAlgebra.empty()
    if ary.size > 0
      if ary[0].is_a? Array
        r = ary.size
        c = 0
        ary.each do |cary|
          c = cary.size if cary.size>c
        end
        r.times do |ri|
          nary=[]
          c.times do |ci|
            if ci<ary[ri].size
              nary << ary[ri][ci]
            else
              nary << d
            end
          end
          m << nary
        end
      elsif ary[0].is_a? Numeric      
        m << ary
      else
        raise "Illegal type=#{ary[0].class.name}"
      end
    end
    #printf("\t[Test] ary:\n%s\n", ary)
    #printf("\t[Test] m:\n%s\n", m)
    return m
  end
  
  # Build-up Identity Matrix
  #
  # Argument
  #   * n: Column/Row number
  # Return 
  #   Matrix object 
  def LinearAlgebra.newIM(n)
    m = Matrix.new
    n.times do |ri|
      ary = []
      n.times do |ci|        
        ary << ((ri==ci)?1:0)        
      end
      m << ary
    end
    m
  end
  
  # Build-up empty Matrix
  def LinearAlgebra.empty()
    return Matrix.new
  end
  
  # Build-up zero Matrix
  #
  # Argument
  #   * r: Row
  #   * c: Column
  # Return
  #   rxc Matrix object with zero value.
  def LinearAlgebra.zeroMtx(r,c)
    return LinearAlgebra.newMtx(r,c)
  end
  
  # Build-up Matrix with default value
  #
  # Argument
  #   * a: Row
  #   * b: Column
  #   * d: Default value
  # Return
  #   axb Matrix object with default value.
  def LinearAlgebra.newMtx(a,b,d=0)
    m = Matrix.new
    if a.is_a? Numeric and b.is_a? Numeric      
      a.times do |i|
        ary = []
        b.times do |j|
          ary << d
        end
        m << ary
      end
    end
    m
  end
  
  # Matrix copy
  #
  # Argument
  #   * m: Matrix to copy
  # Return
  #   Another Matrix object with same content as input Matrix<m>.
  def LinearAlgebra.copyMtx(m)
    nm = Matrix.new
    m.content.each do |r|
      nm.content << Array.new(r)
    end
    nm
  end
  
  # Build-up Square Matrix with default value.
  def LinearAlgebra.newSMtx(s,d)
    m = Matrix.new
    s.times do |r|
      ary = []
      s.times do |c|
        ary << d
      end
      m << ary
    end
    m
  end
  
  # Build-up Matrix with default values in array.
  #
  # Argument
  #   * r: Row
  #   * c: Column
  #   * v: Default value array
  #   * d: Default value if <v> has less values for created matrix.
  # Return
  #   Matrix object.
  def LinearAlgebra.newMtx3(r,c,v,d=0)
    m = Matrix.new
    i=0
    r.times do |ri|
      col=[]
      c.times do |ci|
        i = ri*c+ci
        if i < v.size
          col << v[i]
        else
          col << d
        end
      end
      m << col
    end
    m
  end
  
  self.singleton_class.send(:alias_method, :eye, :newIM)
end

class Vector
  attr_accessor :content
    
  def initialize(a=[])
    @content=a
  end
  
  def *(that)    
    if that.is_a? Numeric
      return @content.map{|v| v*that}
    else
      raise "Only Vector support as input!"
    end    
  end
  
  def to_s
    return @content.to_s
  end
end

class Matrix
  include MtxOp
  
  attr_accessor :content
  
  def initialize()
    @content=[]
  end
  
  def swapRow!(r1, r2)
    if r1 != r2
      rsize=row()
      if r1 < rsize and r2 < rsize
        @content[r1],@content[r2]=@content[r2],@content[r1]
        return true
      else
        raise "#{r1}/#{r2} should less than row size=#{rsize}!"
      end
    end
    return false
  end
  
  def shape
    return [row(), col()]
  end
  
  def row2Mtx(r)
    if r < self.row
      LinearAlgebra.A2M([@content[r]])
    else
      raise "Out of boundary! (#{r} > Row size=#{row})"
    end
  end
  
  def row()
    return @content.size
  end
  
  def col2Mtx(c)
    tAry = col2Ary(c)
    colAry = []
    tAry.each do |v|; colAry << [v]; end;
    LinearAlgebra.A2M(colAry)
  end
  
  def col2Ary(c)
    if @content.size > 0
      if col() > c
        ary = []
        @content.each do |row|
          ary << row[c]
        end  
        return ary
      else
        raise "Out of boundary! (#{c} > Column size=#{col})"
      end
    else
      return []
    end
  end
  
  def col()
    if @content.size > 0
      return @content[0].size
    else
      return 0
    end
  end
  
  def <<(that)
    @content << that
  end
  
  def *(that)    
    m = nil
    if that.is_a? Matrix
      m = LinearAlgebra.empty
      raise "Illegal: #{self.row}x#{self.col} * #{that.row}x#{that.col}" if self.col != that.row       
      self.row.times do |r|
        ary = []
        that.col.times do |tc|
          v=0
          self.col.times do |c|
            v+=self[r,c]*that[c,tc]
          end
          ary << v
        end
        m << ary
      end
    elsif that.is_a? Numeric
      m = LinearAlgebra.copyMtx(self)
      self.row.times do |r|
        self.col.times do |c|
          m[r,c]*=that
        end
      end
    end
    m
  end
  
  def +(that)
    m = LinearAlgebra.copyMtx(self)
    if that.is_a? Matrix and (self.col==that.col and self.row==that.row)
      self.row.times do |r|
        self.col.times do |c|
          m[r,c]+=that.content[r][c]
        end
      end
    elsif that.is_a? Numeric
      self.row.times do |r|
        self.col.times do |c|
          m[r,c]+=that
        end
      end
    else
      raise "Unknown Type For Matrix '+' Operation: #{that.class.name}!"
    end
    m
  end

  def -(that)    
    m = LinearAlgebra.copyMtx(self)
    if that.is_a?(Matrix) and (self.col==that.col and self.row==that.row)      
      self.row.times do |r|
        self.col.times do |c|
          m[r,c]-=that.content[r][c]
        end
      end
    elsif that.is_a? Numeric      
      self.row.times do |r|
        self.col.times do |c|
          m[r,c]-=that
        end
      end
    else
      raise "Fail in Matrix '-' operation!:\n#{self}\n-----------\n#{that}\n"
    end
    m
  end
  
  def /(that)
    m = LinearAlgebra.copyMtx(self)
    if that.is_a? Matrix and (self.col==that.col and self.row==that.col)
      self.row.times do |r|
        self.col.times do |c|
          m[r,c]=m[r,c].to_f/that.content[r][c].to_f
        end
      end
    elsif that.is_a? Numeric
      self.row.times do |r|
        self.col.times do |c|
          m[r,c]=m[r,c]/that.to_f
        end
      end
    end
    m
  end
  
  def []=(row, col, val)
    @content[row][col]=val
  end  
  
  def [](row, col=nil)
    if col!=nil
      return @content[row][col]
    else
      return LinearAlgebra.A2M(@content[row])
    end
  end

  def ==(amtx)
    if amtx.is_a? Matrix and (self.row==amtx.row and self.col==amtx.col)
      self.row.times do |r|
        self.col.times do |c|
          return false if self[r,c]!=amtx[r,c]
        end
      end
      return true
    end
    return false
  end
  
  def sum
    s=0
    @content.each do |v|
      v.each do |i|
        s+=i
      end
    end
    s
  end
  
  def to_a
    nary = []
    @content.each do |v|
      nary << v
    end
    nary
  end
  
  def to_s
    str_buf=""
    @content.each do |v|
      v.each do |i|
        str_buf+="#{i}\t"
      end
      str_buf+="\n"
    end    
    return str_buf
  end
end

class Fixnum
  alias_method :sup_mlt, :*
  def *(other)
    if other.is_a? Matrix
      return other*self
    else
      return self.sup_mlt(other)
    end
  end  
end

class Float
  alias_method :sup_pls, :*
  def *(other)
    if other.is_a? Matrix
      return other*self
    else
      return self.sup_mlt(other)
    end
  end  
end