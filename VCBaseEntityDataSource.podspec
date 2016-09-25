Pod::Spec.new do |s|
  s.name     = 'VCBaseEntityDataSource'
  s.version  = '1.0.0'
  s.ios.deployment_target = '6.1'
  s.license  = { :type => 'MIT', :text => '<<MIT License
Copyright (C) 2011 by Vinay Chavan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.' }
  s.summary  = 'A clean CoreData stack.'
  s.homepage = 'https://github.com/davinc/VCBaseEntityDataSource'
  s.authors   = { 'Vinay Chavan' => 'davinc@me.com' }
  s.source   = { :git => 'https://github.com/davinc/VCBaseEntityDataSource.git', :tag => s.version.to_s }

  s.description = 'This is a base class of other entity data sources, This class is responsible for handling core data manipulation and sorting. This class hides implementaion of NSFetchedResultsController from caller.'

  s.source_files = 'VCBaseEntityDataSource.{h,m}'
  s.framework    = 'CoreData'
  s.requires_arc = true
end
