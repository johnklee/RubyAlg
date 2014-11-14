require "alg/sort/SortMod"

class HeapSort
  # http://localhost/jforum/posts/list/963.page
  include SortMod
  
  # Get Parent
  #             0
  #           1   2
  #          3 4 5 6
  #  p = (c-1)/2
  #  c=1 -> (1-1)/2 = 0
  #  c=2 -> (2-1)/2 = 0
  #  c=3 -> (3-1)/2 = 1
  #  c=4 -> (4-1)/2 = 1
  #  c=5 -> (5-1)/2 = 2
  #  c=6 -> (6-1)/2 = 2  
  @@GP=lambda{|c| (c-1)/2}
  
  # Get Child
  #             0
  #           1   2
  #          3 4 5 6
  # c = (p*2+1, p*2+2)
  # p=0 -> 0*2+1=1, 0*2+2=2
  # p=1 -> 1*2+1=3, 1*2+2=4
  # p=2 -> 2*2+1=5, 2*2+2=6
  @@GC=lambda{|p| [p*2+1,p*2+2]}     
    
  # Build heap-tree
  def _ad_heap(ary, cmp, size)
    (size-1).downto(1) do |i|
      p=@@GP.call(i)
      while p>=0
        if cmp.call(ary[i], ary[p])==1
          swap(ary, i, p)
          i=p
          p=@@GP.call(p)
        else
          break
        end
      end
    end
  end
  
  def csort(ary, cmp)
    if ary.size > 1
      ary.size.downto(2) do |i|
        _ad_heap(ary, cmp, i)
        #printf("HeapTree(%d)=%s\n", i, ary)
        swap(ary, 0, i-1)
      end      
    end
    ary 
  end
end