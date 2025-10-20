#include <tna.p4>

header ethernet_t {
    bit<48> dst_addr;
    bit<48> src_addr;
    bit<16> ether_type;
}

struct headers {
    ethernet_t ethernet;
}

parser parse_packet(
    packet_in packet,
    out headers hdr,
    inout standard_metadata_t standard_metadata) {
    
    state start {
        packet.extract(hdr.ethernet);
        transition accept;
    }
}

control ingress(
    inout headers hdr,
    inout standard_metadata_t standard_metadata) {
    
    action forward(bit<9> port) {
        standard_metadata.egress_spec = port;
    }
    
    action drop() {
        mark_to_drop(standard_metadata);
    }
    
    table mac_table {
        key = {
            hdr.ethernet.dst_addr: exact;
        }
        actions = {
            forward;
            drop;
        }
        size = 1024;
        default_action = drop;
    }
    
    apply {
        mac_table.apply();
    }
}

control egress(
    inout headers hdr,
    inout standard_metadata_t standard_metadata) {
    
    apply {
    }
}

control deparse_packet(
    packet_out packet,
    in headers hdr) {
    
    apply {
        packet.emit(hdr.ethernet);
    }
}

V1Switch(
    parse_packet(),
    verify_checksum(),
    ingress(),
    egress(),
    compute_checksum(),  
    deparse_packet()
) main;
