require "alg/sort/SortMod"

class QuickSort
  # http://localhost/jforum/posts/list/962.page
  include SortMod
  
  def qsort(ary, cmp, h, t)
    if(h+1==t)
      swap(ary, h, t) if cmp.call(ary[h], ary[t])==1
    elsif h<t
      m=0; left=h+1; right=t
      while left<right
        if cmp.call(ary[h], ary[left])==1
          # Keep looking for value smaller than head
          left+=1
          next    
        end      
        if cmp.call(ary[h], ary[right])==-1
          # Keep looking for value bigger than head 
          right-=1
          next
        end                    
        
        # Swap big to left side; samll to right side
        swap(ary, left, right)
        left+=1
        right-=1                       
      end # while
           
      right-=1 if cmp.call(ary[h], ary[right]) == -1
      swap(ary, h, right)
      qsort(ary, cmp, h, right-1)
      qsort(ary, cmp, right+1, t)
    end      
    ary
  end
  
  def csort(ary, cmp)
    return qsort(ary, cmp, 0, ary.size-1)
  end
end