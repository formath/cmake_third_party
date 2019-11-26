#include <string>
#include <glog/logging.h>
#include <boost/any.hpp>
#include <city.h>

void init_glog(char* name) {
  google::InitGoogleLogging(name);
  google::SetLogDestination(google::GLOG_INFO, "./demo.log.info");
  google::SetLogDestination(google::GLOG_WARNING, "./demo.log.warning");
  google::SetLogDestination(google::GLOG_ERROR, "./demo.log.error");
  google::SetLogDestination(google::GLOG_FATAL, "./demo.log.fatal");
}

int main(int argc, char* argv[]) {
  init_glog(argv[0]);
  LOG(INFO) << "hello world";

  // boost
  try {
    boost::any a = 1;
    LOG(INFO) << boost::any_cast<int>(a);
  } catch (boost::bad_any_cast &e) {
    LOG(ERROR) << e.what();
  }

  // cityhash
  std::string t("hello");
  uint64_t sign = CityHash64(t.c_str(), t.size());
  LOG(INFO) << sign;

  return 0;
}