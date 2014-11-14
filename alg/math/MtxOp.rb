module MtxOp
  # Gaussian elimination: http://en.wikipedia.org/wiki/Gaussian_elimination 
  #
  # Return
  #   Return a upper triangular matrix after Gaussian elimination or raise runtime error. 
  def gelm()
    m = LinearAlgebra.copyMtx(self)
    d = [m.row, m.col].min # Dimension of matrix
    d.times do |pi|
      # Find the k-th pivot:
      if m[pi,pi] == 0
        # i_max  := argmax (i = k ... m, abs(A[i, k]))
        i_max=0
        i=0
        (pi+1...d).each do |ri|
          if (m[ri,pi])>i_max
            i_max = m[ri,pi]
            i = ri
          end
        end

        if i_max == 0
          raise "Matrix is singular!"
        end
        m.swapRow!(pi,i)
      end

      # Do for all rows below pivot:
      (pi+1...d).each do |ri|
        # Do for all remaining elements in current row:
        (pi+1...d).each do |ci|
          # A[i, j]  := A[i, j] - A[k, j] * (A[i, k] / A[k, k])
          m[ri,ci] = m[ri,ci] - m[pi,ci]*(m[ri,pi]/m[pi,pi].to_f)
        end
        # Fill lower triangular matrix with zeros:
        m[ri,pi]=0
      end
    end
    m
  end
  
  # 一方陣 A 為奇異(singular)矩陣，若 |A| = 0
  def isSingular?
    return self.det()==0
  end
  
  # Square matrix?
  def isSquare?
    return self.row==self.col
  end
  
  # 對角矩陣(diagonal matrix)?
  def isDiagonal?
    if self.row == self.col
      self.row.times do |r|
        return false if self[r].inject{|sum,i|sum+i}!=self[r,r]
      end
      return true
    end
    return false
  end
  
  # 單位矩陣(identity matrix)?
  def isIdentity?
    if self.row == self.col
      self.row.times do |r|
        return false if self[r,r]!=1 || (self[r].inject{|sum,i|sum+i}!=self[r,r])
      end
      return true
    end
    return false
  end
  
  # Symmetrix Matrix?
  def isSymmetric?
    return self == self.t
  end
  
  # 轉置矩陣
  def t
    m = LinearAlgebra.newMtx(self.col, self.row)
    self.row.times do |r|
      self.col.times do |c|
        m[c,r]=self[r,c]
      end
    end
    m
  end
  
  # 軌跡 Trace of a Matrix
  def tr
    sum=0
    [self.col, self.row].min.times do |i|
      sum+=self[i,i]
    end 
    return sum
  end
  
  # 行列式 Determinant: http://en.wikipedia.org/wiki/Determinant
  def det
    d=self.row    
    return self[0,0]*self[1,1]-self[0,1]*self[1,0] if d==2
    return self[0,0] if d==1
    rs=0
    ls=0
    self.row.times do |r|
      rv=1
      lv=1
      self.col.times do |c|
        #printf("r:[%d][%d]/l:[%d][%d] ", c, (r+c)%d, c, r-c)
        rv*=self[c,(r+c)%d]
        lv*=self[c,r-c]
      end      
      rs+=rv
      ls+=lv
      #printf("=%s|%s (%s|%s)\n", rv, lv, rs, ls)
    end
    return rs-ls
  end
  
  # 餘子式 Minor: http://en.wikipedia.org/wiki/Minor_(linear_algebra)
  def m(r,c)
    m = LinearAlgebra.empty()
    self.row.times do |ri|
      next if ri==r
      ary =[]
      self.col.times do |ci|
        next if ci==c
        ary << self[ri,ci]
      end
      m << ary
    end
    #printf("\t[Test] m(%d/%d,%d/%d):\n%s\n", r, self.row,c, self.col,m)
    m.det
  end
  
  # 伴隨矩陣 Adjugate matrix:http://en.wikipedia.org/wiki/Adjugate_matrix
  def adj()
    m = LinearAlgebra.newMtx(self.row, self.col)
    self.row.times do |ri|
      self.col.times do |ci|
        m[ri,ci]=self.m(ri,ci)*((-1)**(ri+ci))
      end
    end
    m.t
  end
  
  # 逆矩陣  Inverse Matrix
  def inv()
    detv = self.det
    if detv!=0
      adjm = self.adj
      #printf("\t[Test] adjm (%s):\n%s\n", detv, adjm)
      return self.adj/detv
    else
      raise "Un-reverse!"
    end  
  end
  
  # Submatrix: http://en.wikipedia.org/wiki/Matrix_(mathematics)#Submatrix
  # 
  # Argument
  #   * r: Deleting row
  #   * c: Deleting column
  # Return
  #   Submatrix of Matrix object.
  def sub(r,c)
    if r<self.row && c<self.col
      m = LinearAlgebra.empty()
      self.row.times do |ri|
        next if ri==r
        ary =[]
        self.col.times do |ci|
          next if ci==c
          ary << self[ri,ci]
        end
        m << ary
      end
      m
    else
      raise "Exceeding Matrix Boundary #{self.row}x#{self.col} for Submatrix(#{r},#{c})!"
    end
  end
end