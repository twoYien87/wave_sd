cmd_net/bluetooth/bluetooth.o := toolchain/bin/arm-linux-gnueabihf-ld -EL    -r -o net/bluetooth/bluetooth.o net/bluetooth/af_bluetooth.o net/bluetooth/hci_core.o net/bluetooth/hci_conn.o net/bluetooth/hci_event.o net/bluetooth/mgmt.o net/bluetooth/hci_sock.o net/bluetooth/hci_sysfs.o net/bluetooth/lib.o net/bluetooth/l2cap_core.o net/bluetooth/l2cap_sock.o net/bluetooth/smp.o net/bluetooth/sco.o 
