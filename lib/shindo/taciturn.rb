module Shindo
  class Tests

    private

    def display_description_stack
      return if @description_stack.empty?
      Thread.current[:formatador].indent do
        Thread.current[:formatador].display_line(@description_stack.pop)
        display_description_stack
      end
    end

    def display_description(description)
      unless @described
        Thread.current[:formatador].display(Thread.current[:file])
        print ' '
        @described = true
      end
    end

    def display_error(error)
      display_description_stack
      Thread.current[:formatador].indent do
        Thread.current[:formatador].display_line("[red]#{error.message} (#{error.class})[/]")
        unless error.backtrace.empty?
          Thread.current[:formatador].indent do
            Thread.current[:formatador].display_lines(error.backtrace.map {|line| "[red]#{line}[/]"})
          end
        end
      end
    end

    def display_failure(description)
      Thread.current[:totals][:failed] += 1
      Thread.current[:formatador].display_line
      display_description_stack
      Thread.current[:formatador].display_line("[red]- #{description}[/]")
    end

    def display_pending(description)
      Thread.current[:totals][:pending] += 1
      print Formatador.parse("[yellow]#[/]")
    end

    def display_success(description)
      Thread.current[:totals][:succeeded] += 1
      print Formatador.parse("[green]+[/]")
    end

    def raises?(expectation, &block)
      value = begin
        instance_eval(&block)
      rescue => error
        error
      end
      [value, value.is_a?(expectation)]
    end

    def returns?(expectation, &block)
      [value = instance_eval(&block), value == expectation]
    end

  end
end
