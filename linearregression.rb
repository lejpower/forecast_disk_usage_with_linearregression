#class 2

require 'mysql2'

class LineArregression

  #attr_accessor :sum_xy, :sum_xx, :sum_x, :sum_y

  def initialize(y_values)
    @sum_x = 0
    @sum_y = 0
    @sum_xx = 0
    @sum_xy = 0

    #initialize everything to 0

    @size = y_values.size
    @x_values = (1..@size).to_a

    # calculate the sums
    y_values.zip(@x_values).each do |y, x|
        @sum_xy += x*y
        @sum_xx += x*x
        @sum_x  += x
        @sum_y  += y
    end #each
    
  end #def initialize

  def cal_slope
    # calculate the slope
    @slope = 1.0 * ((@size * @sum_xy) - (@sum_x * @sum_y)) / ((@size * @sum_xx) - (@sum_x * @sum_x))
    @intercept = 1.0 * (@sum_y - (@slope * @sum_x)) / @size

    return @slope , @intercept
  end #slope

  def forcast_line
    forcast_value = Array.new
    @x_values.each_with_index do |x , i|
      forcast_value[i] = (@slope*x) + @intercept
    end
    
    return forcast_value
  end #forcast_line

  def predict_max(size)
    forcast_max = (size-@intercept)/@slope

    return forcast_max    
  end #predict_max

end #class

#class 2
class Connection_db
  def connection_db(host, user, port, password, db, id)
    result_used = Array.new
    result_total = Array.new

    client = Mysql2::Client.new(:host => host, :port => port,  :username => user, :password => password, :database => db)
    client.query("SELECT total, used  FROM disks where instance_id = '#{id}'").each_with_index do |result, i|
      result_used[i] = result['used']
      result_total[i] = result['total']
    end
    
    return result_used, result_total
  end
end #class



###############
#main         #
###############
    id = ARGV[0]
    connection = Connection_db.new()
    y_values , total = connection.connection_db('localhost', 'root', 3306, '${PASSWORD}', '${DB_NAME}', id)
    #y_values = [1534,1654,9854,2467,6784,4326,8567,3452,8567,9784]
    p "#y_values#"
    p y_values
    p "-------------------"
    p " "

    predict_disk = LineArregression.new(y_values)
    
    #p predict_disk.sum_xy
    #p predict_disk.sum_xx
    #p predict_disk.sum_x
    #p predict_disk.sum_y

   slope, intercept = predict_disk.cal_slope()
    p "#slope, intercept#"
    p slope
    p intercept
    p "-------------------"
    p " "

    forcast_line = predict_disk.forcast_line()

    disk_max = total.last
    p "###disk max###"
    p disk_max
    p "##############"
    p ""
    p "### forcast_max ###"
    forcast_max = predict_disk.predict_max(disk_max)
    tmp_forcast = forcast_max.ceil.to_i.divmod(60)
    p tmp_forcast[0].div(24)
    p "remaining days"
