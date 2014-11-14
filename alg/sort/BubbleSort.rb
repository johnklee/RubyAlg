require "alg/sort/SortMod"

class BubbleSort
  # http://localhost/jforum/posts/list/936.page
  include SortMod
  
  def csort(ary, cmp)    
    ary.size.downto(1) do |i|
      (1..i).each do |j|
        if (cmp.call(ary[j-1], ary[j])==1)
          #ary[j],ary[j-1]=ary[j-1],ary[j]
          swap(ary, j, j-1)
        end
      end
    end
    ary
  end
end