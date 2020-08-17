//
//  BN.swift
//  JWTKit
//
//  Created by Alex Tran-Qui on 17/08/2020.
//

import Foundation
import CJWTKitBoringSSL

class BN {
    let c: UnsafeMutablePointer<BIGNUM>?;

     public init() {
        self.c = CJWTKitBoringSSL_BN_new();
    }

     init(_ ptr: OpaquePointer) {
        self.c = UnsafeMutablePointer<BIGNUM>(ptr);
    }

     deinit {
        CJWTKitBoringSSL_BN_free(self.c);
    }

     public static func convert(_ bnBase64: String) -> BN? {
        guard let data = Data(base64Encoded: bnBase64) else {
            return nil
        }

        // TODO: confirm - was Int32(p.count) in original code
         let c = data.withUnsafeBytes { (p: UnsafeRawBufferPointer) -> OpaquePointer in
            return OpaquePointer(CJWTKitBoringSSL_BN_bin2bn(p.baseAddress?.assumingMemoryBound(to: UInt8.self), p.count, nil))
        };
        return BN(c);
    }

     public func toBase64(_ size: Int = 1000) -> String {
        let pBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size);
        defer { pBuffer.deallocate() };

         let actualBytes = Int(CJWTKitBoringSSL_BN_bn2bin(self.c, pBuffer));
        let data = Data(bytes: pBuffer, count: actualBytes);
        return data.base64EncodedString();
    }
}
