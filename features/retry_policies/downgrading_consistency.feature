Feature: Downgrading Consistency Retry Policy

  The Downgrading Consistency retry policy retries failed queries with a lower
  consistency level than the one initially requested.

  BEWARE: By doing so, it may break consistency guarantees. In other words, if
  you use this retry policy, there are cases where a read at QUORUM may not see
  a preceding write at QUORUM. Do not use this policy unless you have
  understood the cases where this can happen and are ok with that.

  Scenario: Downgrading Consistency policy is used explicitly
    Given a running cassandra cluster with a schema "simplex" and a table "songs"
    And the following example:
      """ruby
      require 'cql'

      cluster = Cql.cluster
                   .with_retry_policy(Cql::Retry::Policies::DowngradingConsistency.new)
                   .build

      session = cluster.connect('simplex')
      result  = session.execute('SELECT * FROM songs', consistency: :all)

      puts "actual consistency: #{result.execution_info.consistency}"
      """
    When node 3 stops
    And it is executed
    Then its output should contain:
      """
      actual consistency: quorum
      """