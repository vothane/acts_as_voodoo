module Query
   class Conditions
      def initialize(&block)
         @columns = []
         block.call(self) unless block.nil?
      end

      def to_where_conditions
         query_strings = []
         arguments     = []

         @columns.each do |column|
         # Get the conditions of each column
         query_string, *column_arguments = column.to_query_condition

            # Append them to the rest
            query_strings << query_string
            arguments << column_arguments
         end

         # Build them up into the right format
         full_query_string = query_strings.join(" AND ")
         full_query_string
      end

      def method_missing(name, *args)
         column = Column.new(name)
         @columns << column
         column
      end
   end

   class Column
      attr_reader :name, :operator, :operand
      def initialize(name)
         @name = name
      end

      OPERATOR_MAP = {
         :== => "=",
         :>= => ">=",
         :<= => "<=",
         :>  => ">",
         :<  => "<",
         :^  => "!=",
         :*  => "IN",
         :=~ => "INCLUDES"
      }

      [:==, :>=, :<=, :>, :<, :^, :*, :=~].each do |operator|
         define_method(operator) do |operand|
            @operator = operator
            if ((operand.instance_of? String) && operator != :*)
               operand = "'#{operand}'"
            end
            @operand = operand
         end

         def to_query_condition
            if [:*, :=~].include? operator
               return "#{name} #{OPERATOR_MAP[operator]} #{operand}"
            else
               return "#{name}#{OPERATOR_MAP[operator]}#{operand}"
            end
         end
      end
   end
end