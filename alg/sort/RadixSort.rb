require "alg/sort/SortMod"

class RadixSort
  # http://localhost/jforum/posts/list/969.page
  include SortMod
  
  def csort(ary, cmp)
    lt=0 # loop time 
    ary.each do |i|
      lt=i.to_s.size if i.to_s.size>lt
    end
    dm={}
    (0..9).each do |j|;dm[j]=[];end
    (0..lt-1).each do|i|      
      ary.each do |j|
        if j.to_s.size < i+1
          dm[0] << j
        else
          dm[j.to_s[-(1+i)].to_i] << j
        end
      end 
      tary=[]     
      (0..9).each do |j|
        tary << dm[j].shift while dm[j].size > 0        
      end
      #printf("[%d]: %s\n", i, tary)
      ary = tary
    end
   
    ary.reverse! if cmp.equal?(@@asc_cmp)
    ary
  end
end