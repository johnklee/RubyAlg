require "alg/ml/MLCore"
require "alg/math/LinearAlgebra"

class NLRegression
  include MLCore
    
  # Standard Linear Regression: http://localhost/jforum/posts/list/2232.page
  #
  # Argument
  #   * xArr: nxm - n=size of instances; m=feature size.
  #   * yArr: 1xm - y=wx
  # Return
  #   w 
  def standRegres(xArr,yArr)
    xMat = LinearAlgebra.A2M(xArr)
    yMat = LinearAlgebra.A2M(yArr).t
    xTx = xMat.t*xMat        
    if xTx.det()==0
      raise "Reverse Matrix Doesn't Exist!"
    end
    xTxr = xTx.inv()    
    xMatt = xMat.t    
    return (xTxr*xMatt)*yMat
  end
  
  # Locally weighted linear regression: http://localhost/jforum/posts/list/2260.page
  #
  # Argument
  #   * testPoint
  #   * xArr
  #   * yArr
  #   * k
  # Return
  #   w
  def lwlr(testPoint,xArr,yArr,k=1.0)
    xMat = LinearAlgebra.A2M(xArr)
    yMat = LinearAlgebra.A2M(yArr).t
    tMat = LinearAlgebra.A2M(testPoint)
    m = xMat.shape[0]
    weights = LinearAlgebra.newIM(m)
    # Create weights matrix
    m.times do |i|
      #printf("%s:%s\n%s\n%s:%s\n%s\n", tMat.class.name, tMat.shape, tMat, xMat[i].class.name, xMat[i].shape, xMat[i])
      diffMat = tMat - xMat[i]      
      printf("\t[Test] diffMat:\n%s\n", diffMat)
      weights[i,i] = Math.exp((diffMat*diffMat.t).sum/(-2.0*k**2))
    end
    xTx = xMat.t * (weights * xMat)
    printf("\t[Test] xTx:\n%s\n", xTx)
    if xTx.inv == 0
      raise "This matrix is singular, cannot do inverse"
    end
    ws = xTx.inv * (xMat.t * (weights * yMat))  
    return tMat * ws
  end
  
  # Locally weighted linear regression: http://localhost/jforum/posts/list/2260.page
  def lwlrWeight(xArr,yArr,k=1.0)
    xMat = LinearAlgebra.A2M(xArr)
    yMat = LinearAlgebra.A2M(yArr).t
    wp = lambda { |testPoint|
      tMat = LinearAlgebra.A2M(testPoint);
      m = xMat.shape[0];
      weights = LinearAlgebra.newIM(m);
      m.times do |i|
        diffMat = tMat - xMat[i]              
        weights[i,i] = Math.exp((diffMat*diffMat.t).sum/(-2.0*k**2))
      end
      xTx = xMat.t * (weights * xMat)    
      if xTx.inv == 0
        raise "This matrix is singular, cannot do inverse"
      end
      ws = xTx.inv * (xMat.t * (weights * yMat))  
      return tMat * ws
    }
    return wp
  end
end