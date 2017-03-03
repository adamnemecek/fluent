import XCTest
@testable import Fluent

class PivotTests: XCTestCase {
    var lqd: LastQueryDriver!
    var db: Database!

    override func setUp() {
        lqd = LastQueryDriver()
        db = Database(lqd)
    }

    func testEntityAttach() throws {
        print("HERE HERE")
        Pivot<Atom, Compound>.database = db
        let atom = Atom(name: "Hydrogen")
        atom.id = 42
        atom.exists = true

        let compound = Compound(name: "Water")
        compound.id = 1337
        compound.exists = true

        try atom.compounds.add(compound)


        guard let query = lqd.lastQuery else {
            XCTFail("No query recorded")
            return
        }

        let (sql, _) = GeneralSQLSerializer(sql: query).serialize()

        XCTAssertEqual(
            sql,
            "INSERT INTO `atom_compound` (`\(lqd.idKey)`, `\(Atom.foreignIdKey)`, `\(Compound.foreignIdKey)`) VALUES (?, ?, ?)"
        )
    }

    static let allTests = [
        ("testEntityAttach", testEntityAttach),
    ]
}
