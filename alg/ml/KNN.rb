require "bigdecimal/util" 
require "alg/ml/MLCore"


module KNN
  include MLCore
      
=begin
  * Name: Classify input instance <inst> with given groups <group> under labels <label>.
  * Description: This api will classify <inst> based on <k> nearlest instance from <group> 
                 and return label belonw to <label>  
  * Author: John Lee
  * Date: 2014/10/23
  * License:
=end
  # Customized API
  def classify(group, label, inst, k, do_norm=false)
    raise RuntimeError, "Muse implement <classify> method!"
  end
end