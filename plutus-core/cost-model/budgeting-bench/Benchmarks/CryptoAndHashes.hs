module Benchmarks.CryptoAndHashes (makeBenchmarks) where

import Common
import Generators

import PlutusCore

import Criterion.Main
import Data.ByteString qualified as BS
import System.Random (StdGen)

import Hedgehog qualified as H

byteStringSizes :: [Int]
byteStringSizes = fmap (100*) [0,2..98]

mediumByteStrings :: H.Seed -> [BS.ByteString]
mediumByteStrings seed = makeSizedByteStrings seed byteStringSizes

bigByteStrings :: H.Seed -> [BS.ByteString]
bigByteStrings seed = makeSizedByteStrings seed (fmap (10*) byteStringSizes)
-- Up to  784,000 bytes.

--VerifySignature : check the results, maybe try with bigger inputs.


---------------- Verify signature ----------------

-- Signature verification functions.  Wrong input sizes cause error, time should
-- be otherwise independent of correctness/incorrectness of signature.

-- For VerifySignature, for speed purposes it shouldn't matter if the signature
-- and public key are correct as long as they're the correct sizes (256 bits/32
-- bytes for keys, 512 bytes/64 bits for signatures).

benchVerifySignature :: Benchmark
benchVerifySignature =
    createThreeTermBuiltinBenchElementwise name [] pubkeys messages signatures
           where name = VerifySignature
                 pubkeys    = listOfSizedByteStrings 50 32
                 messages   = bigByteStrings seedA
                 signatures = listOfSizedByteStrings 50 64
-- TODO: this seems suspicious.  The benchmark results seem to be pretty much
-- constant (a few microseconds) irrespective of the size of the input, but I'm
-- pretty certain that you need to look at every byte of the input to verify the
-- signature.  If you change the size of the public key then it takes three
-- times as long, but the 'verify' implementation checks the size and fails
-- immediately if the key or signature has the wrong size.

benchVerifyEcdsaSecp256k1Signature :: Benchmark
benchVerifyEcdsaSecp256k1Signature =
    createThreeTermBuiltinBenchElementwise name [] pubkeys messages signatures
        where name = VerifyEcdsaSecp256k1Signature
              pubkeys    = listOfSizedByteStrings 50 64
              messages   = listOfSizedByteStrings 50 32
              signatures = listOfSizedByteStrings 50 64


benchVerifySchnorrSecp256k1Signature :: Benchmark
benchVerifySchnorrSecp256k1Signature =
    createThreeTermBuiltinBenchElementwise name [] pubkeys messages signatures
        where name = VerifySchnorrSecp256k1Signature
              pubkeys    = listOfSizedByteStrings 50 64
              messages   = bigByteStrings seedA
              signatures = listOfSizedByteStrings 50 64


benchByteStringOneArgOp :: DefaultFun -> Benchmark
benchByteStringOneArgOp name =
    bgroup (show name) $ fmap mkBM (mediumByteStrings seedA)
           where mkBM b = benchDefault (showMemoryUsage b) $ mkApp1 name [] b

makeBenchmarks :: StdGen -> [Benchmark]
makeBenchmarks _gen =  [benchVerifySignature, benchVerifyEcdsaSecp256k1Signature, benchVerifySchnorrSecp256k1Signature]
                    <> (benchByteStringOneArgOp <$> [ Sha2_256, Sha3_256, Blake2b_256 ])

-- Sha3_256 takes about 2.65 times longer than Sha2_256, which in turn takes
-- 2.82 times longer than Blake2b.  All are (very) linear in the size of the
-- input.
