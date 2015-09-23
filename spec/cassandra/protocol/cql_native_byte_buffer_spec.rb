# encoding: ascii-8bit

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

require 'spec_helper'
require_relative 'cql_byte_buffer_shared_examples'

if defined? Cassandra::Protocol::CqlNativeByteBuffer
  describe Cassandra::Protocol::CqlNativeByteBuffer do
    it_behaves_like "protocol byte buffer implementation"
  end
end