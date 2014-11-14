require "alg/sort/SortMod"

class InsertSort
  # http://localhost/jforum/posts/list/940.page
  include SortMod
  
  def csort(ary, cmp)
    if(ary.size>1)
      (1..ary.size-1).each do |i|
        while i>0
          if cmp.call(ary[i-1], ary[i])==1
            swap(ary, i-1, i)
            i-=1
          else
            break            
          end
        end
      end
    end
    ary    
  end
end