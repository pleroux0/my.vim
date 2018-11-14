from conans import ConanFile, tools

class GoodConan(ConanFile):
    name = "good"
    version = "1.0"
    description = "A package that does very simple operations for testing"
    license = "BSD"
    generators = "cmake"

    def source(self):
        self.run("touch test_source")

    def build(self):
        self.run("touch test_build")

    def package_info(self):
        self.run("touch test_package")
