require 'bundler/setup'
require 'cassandra'
require 'benchmark/ips'
require 'benchmark'

Cassandra::Protocol.cql_byte_buffer_class = Cassandra::Protocol::CqlNativeByteBuffer

def session
  cluster = Cassandra.cluster(hosts: ['127.0.0.1'], futures_factory: Cassandra::Future::Factory.new(Cassandra::Executors::SameThread.new))
  # cluster = Cassandra.cluster(hosts: ['127.0.0.1'])
  cluster.connect("simplex")
end

def prepare_schema(session)
  session.execute <<-CQL
    CREATE TABLE IF NOT EXISTS series_v2(
      id          INT,
      cluster     TEXT,
      year        INT,
      date        TEXT,
      subcluster  TEXT,
      value       map<int, int>,

      PRIMARY KEY ((id, cluster, year), date, subcluster)
    )
  CQL
end

def clear_schema(session)
  session.execute("TRUNCATE series_v1");
end

def prepared_upsert(session)
  session.prepare <<-CQL
    UPDATE series_v2 SET value = value + ?
    WHERE id = ? AND cluster = ? AND year = ? AND date = ? AND subcluster = ?
  CQL
end

def run_upserts(session, query, values)
  futures = values.map {|args| session.execute_async(query, arguments: args)}
  Cassandra::Future.all(futures).get
end

def sample_values
  clusters = ['ABC', 'XYZ']
  subclusters = ['123', '456']
  ids = (1..5).to_a
  t = Time.now
  year = t.year

  values = []
  clusters.each {|cluster|
    subclusters.each {|subcluster|
      ids.each {|id|
        values << [
          {rand(10) => rand(10)},
          id,
          cluster,
          year,
          t.to_date.to_s,
          subcluster,
        ]
      }
    }
  }

  values
end

srand
s = session
prepare_schema(s)
clear_schema(s)
q = prepared_upsert(s)
v = sample_values

# Benchmark.ips do |x|
#   x.report('upserts') {
#     run_upserts(s, q, v)
#   }
# end

# Benchmark.ips do |x|
#   x.report('CqlByteBuffer') {
#     Cassandra::Protocol.cql_byte_buffer_class = Cassandra::Protocol::CqlByteBuffer
#     run_upserts(s, q, v)
#   }

#   x.report('CqlNativeByteBuffer') {
#     Cassandra::Protocol.cql_byte_buffer_class = Cassandra::Protocol::CqlNativeByteBuffer
#     run_upserts(s, q, v)
#   }

#   x.compare!
# end

## Perfs

nruns = 10
l = lambda {50.times {run_upserts(s, q, v)}}

require 'ruby-prof'

puts "Warming up ..."
l.call

total_t = 0.0
puts "Profiling ..."
RubyProf.start
nruns.times {
  bm = Benchmark.realtime {l.call}
  puts "Run completed in #{"%.3f" % bm}s"
  total_t += bm
}
result = RubyProf.stop

puts "Avg run time #{"%.3f" % (total_t / nruns)}s\n"
puts "Generating Profiles ..."

printer = RubyProf::GraphHtmlPrinter.new(result)
File.open("/tmp/profile-graph-1.html", 'w') {|f| printer.print(f)}

printer = RubyProf::FlatPrinter.new(result)
File.open("/tmp/profile-flat-1.txt", 'w') {|f| printer.print(f, sort_method: :total_time)}

puts "Done."
