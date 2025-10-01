#include <core.p4>
#include <v1model.p4>

// HEADER
header ethernet {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType; // protocol type
}

struct AllHeaders {
    ethernet eth;
}

// METADATA
struct metadata {
    bit<9> ingress_port;
    bit<9> egress_port;
    bit<1> is_unicast; // if == 1: floods()
}

// PARSER (disassembles the package)
parser MyParser(packet_in pkt, out headers hdr, inout metadata meta) {
    state start {
        pkt.extract(hdr.eth);
        transition accept;
    }
}

control MyIngress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    // table to learn MAC addresses and its corresponding ports
    table mac_learning_table {
        key = {
            hdr.eth.dstAddr : exact @name("dst_mac");
        }
        actions = {
            _NoAction;
            forward;
            set_egress_port_and_learn;
        }
        default_action = _NoAction();
        size = 1024;
    }

    action forward(bit<9> port) {
        meta.egress_port = port;
        meta.is_unicast = 1;
    }
    
    action set_egress_port_and_learn(bit<9> port) {
        meta.egress_port = port;
        meta.is_unicast = 1;
    }

    apply {
        meta.ingress_port = standard_metadata.ingress_port;
        // Simplifying:
        // 1. Lookup with destiny MAC address.
        // 2. If matches, forward.
        // 3. Else, flood.

        mac_learning_table.apply();

        if (mac_learning_table.hit) {
        } else {
            // destiny MAC address unknown - FLOOD
            meta.egress_port = standard_metadata.recirculate_port;
            meta.is_unicast = 0;
        }
    }
}

// DEPARSER
control MyDeparser(packet_out pkt, in headers hdr) {
    apply {
        pkt.emit(hdr.eth);
    }
}

// PROGRAM INSTANCE
V1Switch(
    MyParser(),
    MyIngress(),
    MyEgress(),
    MyDeparser()
)

