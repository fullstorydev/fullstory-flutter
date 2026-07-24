# frozen_string_literal: true

require "xcodeproj"

project_path = ARGV.fetch(0)
package_path = ARGV.fetch(1)
product_name = ARGV.fetch(2, "fullstory-flutter")

project = Xcodeproj::Project.open(project_path)
test_target = project.targets.find { |target| target.name == "RunnerTests" }
abort("RunnerTests target not found in #{project_path}") unless test_target

package = project.root_object.package_references.find do |reference|
  reference.respond_to?(:relative_path) &&
    reference.relative_path == package_path
end

unless package
  package = project.new(
    Xcodeproj::Project::Object::XCLocalSwiftPackageReference
  )
  package.relative_path = package_path
  project.root_object.package_references << package
end

product = test_target.package_product_dependencies.find do |dependency|
  dependency.product_name == product_name
end

unless product
  product = project.new(
    Xcodeproj::Project::Object::XCSwiftPackageProductDependency
  )
  product.package = package
  product.product_name = product_name
  test_target.package_product_dependencies << product
end

unless test_target.frameworks_build_phase.files.any? do |build_file|
         build_file.product_ref == product
       end
  build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  build_file.product_ref = product
  test_target.frameworks_build_phase.files << build_file
end

project.save
