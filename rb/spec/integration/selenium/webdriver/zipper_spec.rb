# encoding: utf-8
#
# Licensed to the Software Freedom Conservancy (SFC) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The SFC licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

require_relative 'spec_helper'

module Selenium
  module WebDriver
    describe Zipper do

      #
      # TODO: clean this spec up
      #

      let(:base_file_name) { "file.txt" }
      let(:file_content)   { "content" }
      let(:zip_file)       { File.join(Dir.tmpdir, "test.zip") }
      let(:dir_to_zip)     { Dir.mktmpdir("webdriver-spec-zipper") }

      def create_file
        filename = File.join(dir_to_zip, base_file_name)
        File.open(filename, "w") { |io| io << file_content }

        filename
      end

      after {
        FileUtils.rm_rf zip_file
      }

      it "zips and unzips a folder" do
        create_file

        File.open(zip_file, "wb") do |io|
          io << Base64.decode64(Zipper.zip(dir_to_zip))
        end

        unzipped = Zipper.unzip(zip_file)
        File.read(File.join(unzipped, base_file_name)).should == file_content
      end

      it "zips and unzips a single file" do
        file_to_zip = create_file

        File.open(zip_file, "wb") do |io|
          io << Base64.decode64(Zipper.zip_file(file_to_zip))
        end

        unzipped = Zipper.unzip(zip_file)
        File.read(File.join(unzipped, base_file_name)).should == file_content
      end

      not_compliant_on :platform => :windows do
        it "follows symlinks when zipping" do
          filename = create_file
          File.symlink(filename, File.join(dir_to_zip, "link"))

          zip_file = File.join(Dir.tmpdir, "test.zip")
          File.open(zip_file, "wb") do |io|
            io << Base64.decode64(Zipper.zip(dir_to_zip))
          end

          unzipped = Zipper.unzip(zip_file)
          File.read(File.join(unzipped, "link")).should == file_content
        end
      end

    end
  end
end
