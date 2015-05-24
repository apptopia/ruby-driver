# encoding: utf-8

#--
# Copyright 2013-2015 DataStax, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#++

module Cassandra
  # @private
  module Executors
    class ThreadPool
      # @private
      class Task
        def initialize(*args, &block)
          @args    = args
          @block   = block
        end

        def run
          @block.call(*@args)
        rescue ::Exception
        ensure
          @args = @block = nil
        end
      end

      def initialize(size)
        @mutex = Mutex.new
        @cv = ConditionVariable.new

        @tasks   = ::Array.new
        @pool    = ::Array.new(size, &method(:spawn_thread))
        @term    = false
      end

      def execute(*args, &block)
        t = Task.new(*args, &block)

        @mutex.synchronize do
          @tasks << t
          @cv.signal
        end

        nil
      end

      def shutdown
        @mutex.synchronize do
          @term = true
          @cv.broadcast
        end

        @pool.each(&:join)

        nil
      end

      private

      def spawn_thread(i)
        Thread.new(&method(:run))
      end

      def run
        Thread.current.abort_on_exception = true

        while !@term
          task = nil

          @mutex.synchronize do
            @cv.wait(@mutex, 3) while !@term && @tasks.empty?
            task = @tasks.shift
          end

          task.run if task
        end
      end
    end

    class SameThread
      def execute(*args, &block)
        yield(*args)
        nil
      rescue ::Exception
        nil
      end

      def shutdown
        nil
      end
    end
  end
end
