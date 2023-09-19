#define CATCH_CONFIG_MAIN

// #include "catch.hpp"
#include <complex>
#include <iostream>
#include <string>

#include <qeventbus.h>
#include <qsubscriber.h>
#include <source_file.hpp>

class TestReceiver : public QObject {
public:
    QString test(int i, QString s) {
        qDebug() << "TestReceiver" << i << s;
        return s + QString::number(i);
    }
};

struct TestMessage {
    int i;
    int j;
};

Q_MESSAGE_META_RESULT(TestMessage, false, false, "test", int)

struct VoidMessage {
    int i;
    int j;
};

Q_MESSAGE_META(VoidMessage, false, false, "void")

int main(int argc, char* argv[]) {
    QCoreApplication a(argc, argv);
    std::cout << "hi";
    QEventBus bus;
    // SimpleMessage
    TestReceiver receiver;
    bus.subscribe("test_topic", QSubscriber(&receiver, &TestReceiver::test));
    bus.publish("test_topic", QStringList({"1", "2"}))
        .then(
            [](QVector<QVariant> const& result) {
                qDebug() << "SimpleMessage public result:" << result;
            },
            [](std::exception& e) { qDebug() << e.what(); });
    return a.exec();
}