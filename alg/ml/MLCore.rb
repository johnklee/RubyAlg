require "alg/math/LinearAlgebra"
# Machine Learning Core APIs

class Array
  def /(that)
    ary=[]
    self.each do |i|
      ary << (i.to_f/that)
    end
    ary
  end
  
  def append(inst)
    self << inst
  end
  
  def combine(that)
    ary=[]
    ms = [self.size, that.size].min
    ms.times do |i|; ary[i]=self[i]+that[i]; end;
    if self.size > that.size
      ary[ms,0]=self[ms..-1]
    elsif self.size < that.size
      ary[ms,0]=that[ms..-1]
    end
    ary
  end
  
  def combine!(that)
    ms = [self.size, that.size].min
    ms.times do |i|
      self[i]=self[i]+that[i]
    end
    if self.size<that.size
      self[ms,0]=that[ms..-1]
    end
  end
  
  def sum()
    s=0
    #printf("\t[Test] %s\n", self)
    self.each do |v|; s+=v; end;
    s
  end
  
  def plus!(that)  
    if that.is_a? Numeric
      self.size.times do |i|
        self[i]=self[i]+that
      end
    elsif that.is_a? Array
      self.size.times do |i|
        self[i]=self[i]+that[i]
      end
    else
      printf("\t[Error] Plus need equal size arrays! (%d/%d)\n", self.size, that.size)
    end    
    self
  end
  
  def plus(that)
    ary = []
    if that.is_a? Numeric
      ary = self.map{|v| v+that}
    elsif that.is_a? Array
      if that.size == self.size
        self.each_with_index do |v, i|
          ary << v.to_f+that[i]
        end
      else
        printf("\t[Error] Plus need equal size arrays! (%d/%d)\n", self.size, that.size)
      end
    end
    ary
  end
  
  def minus(that)
    ary = []
    if that.is_a? Numeric
      ary = self.map{|v| v-that}
    elsif that.is_a? Array
      if that.size == self.size
        self.each_with_index do |v, i|
          ary << v.to_f-that[i]
        end
      end
    end
    ary
  end
  
  def multi(that)
    ary = []    
    if that.is_a? Numeric
      self.each do |i|
        if i.is_a? Array
          ary << i.multi(that)          
        else
          ary << i.to_f*that
        end
      end
    elsif that.is_a? Array
      if that.size == self.size
        self.each_with_index do |v, i|
          if v.is_a? Array
            ary << v.multi(that[i])
          else                       
            ary << (that[i]*(v.to_f))
            #printf("\t[Test] %s*%s: %s\n", that[i], v.to_f, ary) 
          end
        end
      end
    end    
    ary
  end
end

module MLCore
  def float(val); val.to_f; end
  def int(val); val.to_i; end
  def zeros(row,col)
    ary=[]
    row.times do
      if col > 0
        ary << Array.new(col,0)
      else
        ary << 0
      end
    end
    ary
  end
  def sign(that)
    if that.is_a? Array
      ary = []
      that.each do |v|
        case 
        when v > 0
          ary << 1
        when v < 0
          ary << -1
        else
          ary << 0
        end
      end
      return ary
    elsif that.is_a? Numeric
      case 
      when that > 0
        return 1
      when that <0
        return -1
      else
        return 0
      end
    else
      return 0
    end
  end
  
  def ones(row,col)
    ary=[]
    row.times do
      if col > 0
        ary << Array.new(col,1)
      else
        ary << 1
      end
    end
    ary
  end
     
  def shape(data)
    if data.is_a? Array
      if data.size > 0
        if data[0].is_a? Array
          return [data.size, data[0].size]
        else
          return [data.size, 1]
        end
      end
    elsif data.is_a? Matrix
      return data.shape
    end
    return [0,0]
  end
    
  def len(dataSet)
    return dataSet.size
  end
  
  def sigmod(inX)
    return 1.0/(1+Math.exp(-inX))
  end

  # Open API: Normalize features of input data to between 0~1.
  def normData(group)
    norm_grp = []
    group.size.times {norm_grp <<[]}
    fs = group[0].size
    fs.times do |i|
      cry = group.collect{|d| d[i]}
      min = cry.min
      max = cry.max
      nrm = (max-min)
      if nrm==0
        group.size.times  do |j|
          norm_grp[j] << 1
        end
      else
        (cry/nrm).each_with_index do |v,j|; norm_grp[j] << v; end;
      end
    end
    #printf("%s->%s\n", group, norm_grp)
    norm_grp
  end
end